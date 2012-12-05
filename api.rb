require 'errors'

class DeployMonitor::API < Sinatra::Base
  API_DOCS = Maruku.new(File.read("README_API.md")).to_html
  DEFAULT_PAGE_ITEMS = 25
  MAX_PAGE_ITEMS = 100

  get '/' do
    erb API_DOCS
  end

  get '/systems' do
    {:systems => System.all.map {|ea| ea.to_hash(:include_steps => true)} }.to_json
  end

  post '/systems' do
    name = params[:name]
    halt 400, Errors.format(:required_param_missing, 'name') unless name

    existing_system = System.filter(:name => name).first
    halt 400, Errors.format(:duplicate_entity, "System '#{name}'", existing_system.id) if existing_system

    system = System.create(:name => name)
    [201, system.to_json]
  end

  get '/systems/:system' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    halt 404, Errors.format(:not_found, "System '#{system_name}'") unless system

    system.to_json(:include_steps => true)
  end

  get '/systems/:system/steps' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    halt 404, Errors.format(:not_found, "System '#{system_name}'") unless system

    {:steps => system.steps }.to_json
  end

  post '/systems/:system/steps' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    if system.nil?
      halt 404, Errors.format(:not_found, "System '#{system_name}'") unless system
    end

    name = params[:name]
    description = params[:description] || ""
    number = params[:number] || system.next_step_number
    halt 400, Errors.format(:invalid_step_number, number) unless number.to_s =~ /\A[0-9]+\Z/
    halt 400, Errors.format(:required_param_missing, 'name') unless name
    name = name.gsub(/ /, '_').downcase

    existing_step = Step.filter(:name => name, :system => system).first
    halt 400, Errors.format(:duplicate_entity, "Step '#{name}'", existing_step.id) if existing_step

    step = DB.transaction do
      Step.renumber_overlapping_steps(system, number)
      Step.create(
        :system => system,
        :name => name,
        :description => description,
        :number => number
      )
    end

    [201, step.to_json]
  end

  get '/steps/:step_id' do
    step_id = params[:step_id]
    step = Step[step_id]
    halt 404, Errors.format(:not_found, "Step id #{step_id}") unless step
    step.to_json
  end

  put '/steps/:step_id' do
    step_id = params[:step_id]
    step = Step[step_id]
    halt 404, Errors.format(:not_found, "Step id #{step_id}") unless step

    step.description = params[:description] if params[:description]
    step.number = params[:number] if params[:number]
    step.save

    step.to_json
  end

  get '/systems/:system/deploys' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    halt 404, Errors.format(:not_found, "System '#{system_name}'") unless system

    deploys = Deploy.filter(:system => system)
    if ['true', 'false'].include?(params[:active])
      active_status = params[:active] == 'true'
      deploys = deploys.filter(:active => active_status)
    end

    pagination = DatasetPagination.new(deploys, DEFAULT_PAGE_ITEMS, MAX_PAGE_ITEMS)
    deploys_page = pagination.paged_dataset(params[:limit], params[:offset])

    {:deploys => deploys_page.all }.to_json
  end

  post '/systems/:system/deploys' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    if system.nil?
      halt 404, Errors.format(:not_found, "System '#{system_name}'")
    end

    active_deploy = Deploy.active.filter(:system => system).first
    if active_deploy
      halt 400, Errors.format(:deploy_in_progress, system_name, active_deploy.id)
    end

    first_step = Step.filter(:system => system).order(:number.asc).first
    unless first_step
      halt 400, Errors.format(:system_has_no_steps, system_name)
    end

    deploy = DB.transaction do
      deploy = Deploy.create(
        :active => true,
        :system => system,
        :started_at => Time.now
      )
      # TODO: This seems like it could be better exposed as a class method on Progress
      progress = Progress.create(:deploy => deploy, :step => first_step, :active => true, :started_at => Time.now)
      deploy
    end

    [201, deploy.to_json]
  end

  get '/deploys/:deploy_id' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, Errors.format(:not_found, "Deploy id #{deploy_id}") unless deploy
    deploy.to_json
  end

  put '/deploys/:deploy_id' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, Errors.format(:not_found, "Deploy id #{deploy_id}") unless deploy

    exclude_from_metadata = ['captures', 'splat', 'deploy_id']
    metadata_params = params.reject {|k, v| exclude_from_metadata.include?(k)}
    deploy.multiset_metadata(metadata_params) unless metadata_params.empty?
    deploy.save

    deploy.to_json
  end

  post '/deploys/:deploy_id/complete' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, Errors.format(:not_found, "Deploy id #{deploy_id}") unless deploy
    halt 400, Errors.format(:deploy_not_active) unless deploy.active
    halt 400, Errors.format(:unknown_result, params[:result]) if params[:result] && Models::RESULTS[params[:result].to_sym].nil?

    result = if params[:result]
      Models::RESULTS[params[:result].to_sym]
    else
      Models::RESULTS[:complete]
    end

    DB.transaction do
      now = Time.now
      Progress.filter(:deploy => deploy, :active => true).update(
        :active => false,
        :finished_at => now,
        :updated_at => now,
        :result => result
      )
      deploy.active = false
      deploy.finished_at = now
      deploy.result = result
      deploy.save
    end

    deploy.to_json
  end

  post '/deploys/:deploy_id/step/:step' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, Errors.format(:not_found, "Deploy id #{deploy_id}") unless deploy
    halt 400, Errors.format(:deploy_not_active) unless deploy.active

    step_name = params[:step]
    step = Step.filter(:system => deploy.system, :name => step_name).first
    if step.nil?
      halt 400, Errors.format(:unknown_step, step_name)
    end
    if deploy.at_step?(step)
      halt 400, Errors.format(:duplicate_deploy_step, step_name)
    end

    progress = DB.transaction do
      now = Time.now
      Progress.filter(:deploy => deploy, :active => true).update(
        :active => false,
        :finished_at => now,
        :updated_at => now,
        :result => Models::RESULTS[:complete]
      )
      progress = Progress.create(:deploy => deploy, :step => step, :active => true, :started_at => now)
      deploy.add_progress(progress)
      deploy.save
      progress
    end

    [201, progress.to_json]
  end
end