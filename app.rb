#!/usr/bin/env ruby -KU -rubygems
require 'ruby-debug'
require 'ostruct'

require 'bundler/setup'
require 'json'
require 'sinatra'
require 'sequel'

DB_URL = 'mysql://root@localhost/rg_test'
DB = Sequel.connect(DB_URL)
require 'models/system'
require 'models/deploy_step'
require 'models/deploy'
require 'models/step'


CONFIG = OpenStruct.new({
  :implicit_system_creation => true,
  :implicit_step_creation => false
})

class DeployMonitor < Sinatra::Base
  get '/' do
    @deploys = Deploy.active
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

    {:steps => DeployStep.filter(:system => system).all }.to_json
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

    existing_step = DeployStep.filter(:name => name).first
    halt 400, "Step '#{name}' already exists with id #{existing_step.id}" if existing_step

    step = DeployStep.create(
      :system => system,
      :name => name,
      :description => description,
      :number => number
    )
    [201, step.to_json]
  end

  get '/steps/:step_id' do
    step_id = params[:step_id]
    step = DeployStep[step_id]
    halt 404, "Step #{step_id} could not be found" unless step
    step.to_json
  end

  put '/steps/:step_id' do
    step_id = params[:step_id]
    step = DeployStep[step_id]
    halt 404, "Step #{step_id} could not be found" unless step

    step.set_fields(params, [:description, :number])
    step.save

    step.to_json
  end

  get '/:system/deploys' do
    system_name = params[:system]
    system = System.filter(:name => system_name).first
    halt 404, "Unknown system '#{system_name}'"

    {:deploys => Deploy.all(:system => system)}.to_json(:naked => true, :include => :steps)
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
      [400, {:error => "Cannot create new deploy for '#{system_name}' because deploy id #{active_deploy.id} is active"}.to_json]
    else
      deploy = Deploy.create(:active => true, :system => system)
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

    deploy.set_fields(params, [:owner, :ticket])
    deploy.save

    deploy.to_json
  end

  post '/deploys/:deploy_id/step/:step' do
    deploy_id = params[:deploy_id]
    deploy = Deploy[deploy_id]
    halt 404, "Deploy #{deploy_id} could not be found" unless deploy

    step_name = params[:step]
    deploy_step = DeployStep.filter(:system => deploy.system, :name => step_name).first
    if deploy_step.nil?
      if CONFIG.implicit_step_creation
        # TODO. Use past steps in current deploy to determine step number
        deploy_step = DeployStep.create(:name => step_name, :system => deploy.system)
      else
        halt 400, "Cannot add unknown step '#{step_name}' to deploy"
      end
    end

    step = DB.transaction do
      now = Time.now
      Step.filter(:deploy => deploy, :active => true).update(:active => false, :completed_at => now)
      Step.create(:deploy => deploy, :deploy_step => deploy_step, :active => true, :started_at => now)
    end

    [201, deploy_step.to_json]
  end
end