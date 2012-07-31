#!/usr/bin/env ruby -wKU -rubygems

require 'uri'
require 'json'
require 'rest-client'

RestClient.log = STDOUT

# Possible Ruby API:
#   deploy_monitor = DeployMonitor.new('http://localhost:4567')
#   deploy = deploy_monitor.start_deploy(:peacock)
#   deploy.progress # => [ ... ]
#   deploy.progress_to(:rpsec_tests, "Running RSpec Ruby tests")
#   deploy.progress_to(:jshint, "Running RSpec Ruby tests")
#   deploy.succeed
#   deploy.fail
# 

class DeployMonitor
  def initialize(host)
    @host = URI.parse(host)
  end

  def start_deploy(system)
    begin
      rsp = RestClient.post "#{@host}/#{system}/deploys", {}
      Deploy.from_api(self, system, JSON.parse(rsp.body))
    rescue RestClient::BadRequest => e
      raise "#{e}: Another deploy is already in progress"
    end
  end

  def get_active_deploy(system)
    rsp = RestClient.get "#{base_url}/#{system}/deploys", :params => {:active => true}
    deploys = JSON.parse(rsp.body)['deploys']
    if deploys.empty?
      nil
    else
      Deploy.from_api(self, system, deploys.first)
    end
  end

  def base_url
    "#{@host}"
  end
end

class Deploy
  attr_accessor :deploy_id, :deploy_monitor, :system

  def self.from_api(deploy_monitor, system, obj)
    deploy = self.new
    deploy.deploy_monitor = deploy_monitor
    deploy.system = system

    deploy.deploy_id = obj['id']

    deploy
  end

  def fail
    RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/complete", {:result => :failure}
  end

  def progress_to(step, description)
    puts self.deploy_id
    RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/step/#{step}", {:description => description}
  end
end

## Sample Usage
deploy_monitor = DeployMonitor.new('http://localhost:4567')
system_name = :frontend

active_deploy = deploy_monitor.get_active_deploy(system_name)
if active_deploy
  puts "There is an existing active deploy for #{system_name} (id ##{active_deploy.deploy_id})."
  print "[U]se this deploy or [a]bort it? (u) "
  decision = STDIN.gets
  deploy = if decision.strip.downcase == 'a'
    active_deploy.fail
    deploy_monitor.start_deploy(system_name)
  else
    active_deploy
  end
else
  deploy = deploy_monitor.start_deploy(system_name)
end

deploy.progress_to(:jshint, "Running RSpec Ruby tests")