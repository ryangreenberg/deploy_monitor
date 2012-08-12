require 'app'
use Rack::Static, :urls => ["/css", "/js"], :root => "public"
run Rack::URLMap.new("/" => DeployMonitor::Web.new, "/api" => DeployMonitor::API.new)