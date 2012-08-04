require 'app'
run Rack::URLMap.new("/" => DeployMonitor::Web.new, "/api" => DeployMonitor::API.new)