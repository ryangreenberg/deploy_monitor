class DeployMonitor::Web < Sinatra::Base
  include TimeUtils

  get '/' do
    @systems = System.all
    erb :index
  end
end
