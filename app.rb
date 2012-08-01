#!/usr/bin/env ruby -KU -rubygems
require 'ostruct'

require 'bundler/setup'
require 'json'
require 'sinatra'
require 'sequel'

DB_URL = 'mysql://root@localhost/rg_test'
DB = Sequel.connect(DB_URL)
require 'models'

CONFIG = OpenStruct.new({
  :implicit_system_creation => true,
  :implicit_step_creation => false
})

class DeployMonitor < Sinatra::Base
  get '/' do
    @systems = System.all
    erb :index
  end

  get '/systems' do
    {:systems => System.all }.to_json
  end

  post '/systems' do
    name = params[:name]
    halt 400, "Missing required param 'name'" unless name

    existing_system = System.filter(:name => name).first
    halt 400, "System '#{name}' already exists with id #{existing_system.id}" if existing_system

    system = System.create(:name => name)
    [201, system.to_json]
  end

  get '/:system/steps' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    halt 404, "Unknown system '#{system_name}'" unless system

    {:steps => Step.filter(:system => system).all }.to_json
  end

  post '/:system/steps' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    if system.nil?
      if CONFIG.implicit_system_creation
        system = System.create(:name => system_name)
      else
        halt 404, "Cannot create new step for unknown system '#{system_name}'"
      end
    end

    name = params[:name]
    description = params[:description] || ""
    number = params[:number] || 0
    halt 400, "Missing required param 'name'" unless name

    existing_step = Step.filter(:name => name).first
    halt 400, "Step '#{name}' already exists with id #{existing_step.id}" if existing_step

    step = Step.create(
      :system => system,
      :name => name,
      :description => description,
      :number => number
    )
    [201, step.to_json]
  end

  get '/steps/:step_id' do
    step_id = params[:step_id]
    step = Step[step_id]
    halt 404, "Step #{step_id} could not be found" unless step
    step.to_json
  end

  put '/steps/:step_id' do
    step_id = params[:step_id]
    step = Step[step_id]
    halt 404, "Step #{step_id} could not be found" unless step

    step.set_fields(params, [:description, :number])
    step.save

    step.to_json
  end

  get '/:system/deploys' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    halt 404, "Unknown system '#{system_name}'" unless system

    deploys = Deploy.filter(:system => system)
    if ['true', 'false'].include?(params[:active])
      active_status = params[:active] == 'true'
      deploys = deploys.filter(:active => active_status)
    end
    {:deploys => deploys.all }.to_json(:naked => true)
  end

  post '/:system/deploys' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    if system.nil?
      if CONFIG.implicit_system_creation
        system = System.create(:name => system_name)
      else
        halt 404, "Cannot create new deploy for unknown system '#{system_name}'"
      end
    end

    active_deploy = Deploy.active.filter(:system => system).first
    if active_deploy
      [400, "Cannot create new deploy for '#{system_name}' because deploy id #{active_deploy.id} is active"]
    else
      deploy = Deploy.create(
        :active => true,
        :system => system,
        :started_at => Time.now
      )
      [201, deploy.to_json]
    end
  end

  get '/deploys/:deploy_id' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, "Deploy #{deploy_id} could not be found" unless deploy
    deploy.to_json
  end

  put '/deploys/:deploy_id' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, "Deploy #{deploy_id} could not be found" unless deploy

    # TODO: This metadata management would be better as a method on Deploy
    exclude_from_metadata = ['captures', 'splat', 'deploy_id']
    metadata_params = params.reject {|k, v| exclude_from_metadata.include?(k)}

    metadata = if deploy.metadata
      JSON.parse(deploy.metadata)
    else
      {}
    end
    metadata_params.each do |k, v|
      if v =~ /null/i
        metadata.delete(k)
      else
        metadata[k] = v
      end
    end

    deploy.metadata = JSON.dump(metadata)
    deploy.save

    deploy.to_json
  end

  post '/deploys/:deploy_id/complete' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, "Deploy #{deploy_id} could not be found" unless deploy
    halt 400, "Deploy #{deploy_id} is not active" unless deploy.active

    result = Models::RESULTS[params[:result].to_sym] || Models::RESULTS[:complete]

    DB.transaction do
      now = Time.now
      Progress.filter(:deploy => deploy, :active => true).update(:active => false, :finished_at => now)
      deploy.active = false
      deploy.result = result
      deploy.save
    end

    deploy.to_json
  end

  post '/deploys/:deploy_id/step/:step' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, "Deploy #{deploy_id} could not be found" unless deploy

    step_name = params[:step]
    step = Step.filter(:system => deploy.system, :name => step_name).first
    if step.nil?
      if CONFIG.implicit_step_creation
        # TODO. Use past steps in current deploy to determine step number
        step = step.create(:name => step_name, :system => deploy.system)
      else
        halt 400, "Cannot add unknown step '#{step_name}' to deploy"
      end
    end

    progress = DB.transaction do
      now = Time.now
      Progress.filter(:deploy => deploy, :active => true).update(
        :active => false,
        :finished_at => now,
        :result => Models::RESULTS[:complete]
      )
      Progress.create(:deploy => deploy, :step => step, :active => true, :started_at => now)
    end

    [201, progress.to_json]
  end
end