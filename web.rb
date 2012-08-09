class DeployMonitor::Web < Sinatra::Base
  include TimeUtils

  get '/' do
    @systems = System.all
    @past_deploys = Deploy.filter(:active => false).order(:finished_at.desc).limit(10)
    erb :index
  end

  get '/deploys/:deploy_id' do
    @deploy = Deploy[params[:deploy_id]]
    @future_steps = if @deploy.active
      Step.filter(:system => @deploy.system) # :number => @deploy.next_step_number)
    else
      []
    end
    halt 404 unless @deploy
    erb :deploy
  end
end
