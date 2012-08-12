class DeployMonitor::Web < Sinatra::Base
  include TimeUtils
  include ViewsHelpers

  get '/' do
    @systems = System.all
    @past_deploys = Deploy.filter(:active => false).order(:finished_at.desc).limit(10)
    erb :index
  end

  get '/deploys/:deploy_id' do
    @deploy = Deploy[params[:deploy_id]]
    halt 404 unless @deploy
    @future_steps = if @deploy.active
      Step.filter(:system => @deploy.system).where{ |o| o.number >= @deploy.next_step_number}
    else
      []
    end
    erb :deploy
  end

  get '/systems/:system_name' do
    @system = System.filter(:name => params[:system_name]).first
    halt 404 unless @system
    @recent_deploys = Deploy.filter(:system => @system).order(:updated_at.desc).limit(10)
    erb :system
  end
end
