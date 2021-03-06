require 'erubis'

class DeployMonitor::Web < Sinatra::Base
  include TimeUtils
  include ViewsHelpers
  DEFAULT_DEPLOY_COUNT = 20
  MAX_DEPLOY_COUNT = 100
  DEFAULT_UPDATE_WINDOW = 10 # seconds

  register Sinatra::Partial
  set :partial_template_engine, :erb

  get '/' do
    @systems = System.all
    @active_deploys = Deploy.filter(:active => true).order(:started_at.desc)
    @past_deploys = Deploy.filter(:active => false).order(:finished_at.desc).limit(DEFAULT_DEPLOY_COUNT)
    erb :index
  end

  get '/deploys/:deploy_id' do
    @deploy = Deploy[params[:deploy_id]]
    halt 404 unless @deploy
    @future_steps = @deploy.future_steps
    erb :deploy
  end

  get '/systems/:system_name' do
    @system = System.filter(:name => params[:system_name]).first
    halt 404 unless @system
    @stats = SystemStatistics.new(@system)
    @step_stats = StepStatistics.new(@system.steps, @system.progresses_from_recent_deploys.all)
    @step_display = StepDisplay.new(@system.steps, @step_stats)
    deploys_dataset = DatasetPagination.new(Deploy.filter(:system => @system).order(:updated_at.desc),
      DEFAULT_DEPLOY_COUNT,
      MAX_DEPLOY_COUNT
    )
    @recent_deploys = deploys_dataset.paged_dataset(params[:limit], params[:offset])
    erb :system
  end

  get '/systems/:system_name/active_deploy' do
    @system = System.filter(:name => params[:system_name]).first
    halt 404 unless @system
    deploy = @system.active_deploy
    redirect(deploy ? Paths.for_deploy(deploy) : Paths.for_system(@system))
  end

  get '/recent_deploys' do
    updated_at = params[:updated_at] ? Time.at(params[:updated_at].to_i) : Time.now - DEFAULT_UPDATE_WINDOW
    deploys = Deploy.filter(:active => false).
      where {|o| o.finished_at >= updated_at }.
      order(:finished_at.desc).
      limit(DEFAULT_DEPLOY_COUNT)

    deploy_htmls = deploys.map do |deploy|
      partial( :deploy_row, :locals => { :include_system => true, :deploy => deploy} )
    end

    {
      :updated_at => Time.now.to_i,
      :deploy_html => deploy_htmls.join('')
    }.to_json
  end

  get '/active_deploy' do
    updated_at = params[:updated_at] ? Time.at(params[:updated_at].to_i) : Time.now - DEFAULT_UPDATE_WINDOW
    deploy = Deploy[params[:id]]
    halt 404 unless deploy

    rsp = {
      :updated_at => Time.now.to_i
    }

    has_new_progress = !Progress.filter(:deploy => deploy).where {|o| o.updated_at > updated_at}.empty?
    if has_new_progress
      progress_rsp = deploy.progresses.map do |progress|
        {
          :id => progress.id,
          :html => partial(:deploy_progress_row, :locals => {:progress => progress})
        }
      end
      future_steps_rsp = deploy.future_steps.map do |step|
        {
          :id => step.id,
          :html => partial(:deploy_step_row, :locals => {:step => step})
        }
      end

      rsp[:deploy_steps] = progress_rsp + future_steps_rsp
      if deploy.active
        rsp[:current_progress] = deploy.current_progress.step.description
        rsp[:progress_percentage] = deploy.progress_percentage
      else
        rsp[:deploy_overview] = partial(:deploy_overview_inactive, :locals => {:deploy => deploy})
      end
    end

    rsp.to_json
  end

  get '/active_deploys' do
    updated_at = params[:updated_at] ? Time.at(params[:updated_at].to_i) : Time.now - DEFAULT_UPDATE_WINDOW
    new_deploys = Deploy.filter(:active => true).
      where {|o| o.started_at >= updated_at }
    # This should just return deploys that have progressed since the last updated at
    continuing_deploys = Deploy.filter(:active => true).
      where {|o| o.started_at < updated_at }
    completed_deploys = Deploy.filter(:active => false).
      where {|o| o.finished_at >= updated_at }

    new_deploys_rsp = new_deploys.map do |deploy|
      {
        :id => deploy.id,
        :html => partial(:active_deploy, :locals => {:deploy => deploy})
      }
    end

    continuing_deploys_rsp = continuing_deploys.map do |deploy|
      {
        :id => deploy.id,
        :current_progress => deploy.current_progress.step.description,
        :progress_percentage => deploy.progress_percentage
      }
    end

    completed_deploys_rsp = completed_deploys.map do |deploy|
      {
        :id => deploy.id
      }
    end

    {
      :updated_at => Time.now.to_i,
      :new_deploys => new_deploys_rsp,
      :continuing_deploys => continuing_deploys_rsp, #continuing_deploys.map {|ea| {:id => ea.id, :current_progress => ea.current_progress.step.description} },
      :completed_deploys => completed_deploys_rsp #completed_deploys.map {|ea| ea.id}
    }.to_json
  end
end
