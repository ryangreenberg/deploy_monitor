#!/usr/bin/env ruby -wKU -rubygems

require 'uri'
require 'json'
require 'rest-client'

# For debugging:
# RestClient.log = STDOUT

# Ruby API:
#   deploy_monitor = DeployMonitor.new('http://localhost:4567')
#   current_deploy = deploy_monitor.current_deploy(:peacock)
#   deploy = deploy_monitor.start_deploy(:peacock)
#   deploy.progress # => [ ... ]
#   deploy.progress_to(:rpsec_tests, "Running RSpec Ruby tests")
#   deploy.progress_to(:jshint, "Running RSpec Ruby tests")
#   deploy.complete
#   deploy.fail

class DeployMonitor
  def initialize(host)
    @host = URI.parse(host)
  end

  def create_system(name)
    RestClient.post "#{@host}/systems", {:name => name}
  end

  def get_system(name)
    RestClient.get "#{@host}/systems/#{name}"
  end

  def start_deploy(system)
    begin
      rsp = RestClient.post "#{@host}/#{system}/deploys", {}
      Deploy.from_api(self, JSON.parse(rsp.body))
    rescue RestClient::BadRequest => e
      raise e, e.response
    end
  end

  def current_deploy(system)
    rsp = RestClient.get "#{base_url}/#{system}/deploys", :params => {:active => true}
    deploys = JSON.parse(rsp.body)['deploys']
    if deploys.empty?
      nil
    else
      Deploy.from_api(self, deploys.first)
    end
  end

  def get_deploy(id)
    begin
      rsp = RestClient.get "#{base_url}/deploys/#{id}"
      Deploy.from_api(self, JSON.parse(rsp.body))
    rescue RestClient::ResourceNotFound => e
      nil
    end
  end

  def base_url
    "#{@host}"
  end
end

class Deploy
  attr_accessor :deploy_id, :deploy_monitor, :active, :progress, :metadata

  TIMESTAMPS = [:created_at, :updated_at, :started_at, :finished_at]
  attr_accessor *TIMESTAMPS

  def self.from_api(deploy_monitor, api_obj)
    deploy = self.new
    deploy.deploy_monitor = deploy_monitor
    deploy.from_api(api_obj)
    deploy
  end

  def from_api(api_obj)
    self.deploy_id = api_obj['id']
    self.active = api_obj['active']
    self.progress = api_obj['progress']
    self.metadata = api_obj['metadata']

    self.created_at = api_obj['created_at'] ? Time.at(api_obj['created_at']) : nil
    self.updated_at = api_obj['updated_at'] ? Time.at(api_obj['updated_at']) : nil
    self.started_at = api_obj['started_at'] ? Time.at(api_obj['started_at']) : nil
    self.finished_at = api_obj['finished_at'] ? Time.at(api_obj['finished_at']) : nil
  end

  def fail
    RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/complete", {:result => :failure}
  end

  def complete
    RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/complete", {:result => :failure}
  end

  def progress_to(step, description)
    RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/step/#{step}", {:description => description}
  end

  def reload
    raise NotImplementedError
  end
end

## Sample Usage
# deploy_monitor = DeployMonitor.new('http://localhost:4567')
# system_name = :frontend
#
# current_deploy = deploy_monitor.current_deploy(system_name)
# if current_deploy
#   puts "There is an existing active deploy for #{system_name} (id ##{current_deploy.deploy_id})."
#   print "[U]se this deploy or [a]bort it? (u) "
#   decision = STDIN.gets
#   deploy = if decision.strip.downcase == 'a'
#     current_deploy.fail
#     deploy_monitor.start_deploy(system_name)
#   else
#     current_deploy
#   end
# else
#   deploy = deploy_monitor.start_deploy(system_name)
# end
#
# deploy.progress_to(:jshint, "Running RSpec Ruby tests")