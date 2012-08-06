class DeployMonitor::Web < Sinatra::Base
  include TimeUtils

  get '/' do
    @systems = System.all
    @past_deploys = Deploy.filter(:active => false).order(:finished_at.desc).limit(10)
    erb :index
  end
end
