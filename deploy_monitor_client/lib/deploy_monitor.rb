require 'uri'
require 'json'
require 'rest-client'

module DeployMonitor
  def self.connect(url)
    DeployMonitor::Client.new(url)
  end
end
require 'deploy_monitor/version'
require 'deploy_monitor/client'
require 'deploy_monitor/api_object'
require 'deploy_monitor/system'
require 'deploy_monitor/step'
require 'deploy_monitor/deploy'
require 'deploy_monitor/exception_silencing_proxy'