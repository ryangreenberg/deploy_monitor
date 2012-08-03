require 'app'
run Rack::URLMap.new("/" => DeployMonitor::UI.new, "/api" => DeployMonitor::API.new)