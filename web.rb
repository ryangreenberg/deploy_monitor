class DeployMonitor::Web < Sinatra::Base
  include TimeUtils
  include ViewsHelpers

  register Sinatra::Partial
  set :partial_template_engine, :erb

  get '/' do
    @systems = System.all
    @active_deploys = Deploy.filter(:active => true).order(:started_at.desc)
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

  get '/recent_deploys' do
    updated_at = Time.at(params[:updated_at].to_i)
    deploys = Deploy.filter(:active => false).
      where {|o| o.finished_at >= updated_at }.
      order(:finished_at.desc).
      limit(10)

    deploy_htmls = deploys.map do |deploy|
      partial( :deploy_row, :locals => { :include_system => true, :deploy => deploy} )
    end

    {
      :updated_at => Time.now.to_i,
      :deploy_html => deploy_htmls.join('')
    }.to_json
  end
end
