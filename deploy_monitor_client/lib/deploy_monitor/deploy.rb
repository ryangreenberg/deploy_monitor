module DeployMonitor
  class Deploy

    class UnknownDeployStep < ArgumentError; end

    attr_accessor :deploy_id, :deploy_monitor, :active, :progress, :metadata

    TIMESTAMPS = [:created_at, :updated_at, :started_at, :finished_at]
    attr_accessor *TIMESTAMPS

    def self.from_api(deploy_monitor, api_obj)
      deploy = self.new
      deploy.deploy_monitor = deploy_monitor
      deploy.update_from_api(api_obj)
      deploy
    end

    def update_from_api(api_obj)
      self.deploy_id = api_obj['id']
      self.active = api_obj['active']
      self.progress = api_obj['progress']
      self.metadata = api_obj['metadata']

      self.created_at = api_obj['created_at'] ? Time.at(api_obj['created_at']) : nil
      self.updated_at = api_obj['updated_at'] ? Time.at(api_obj['updated_at']) : nil
      self.started_at = api_obj['started_at'] ? Time.at(api_obj['started_at']) : nil
      self.finished_at = api_obj['finished_at'] ? Time.at(api_obj['finished_at']) : nil
    end

    def progress_to(step, description)
      begin
        RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/step/#{step}", {:description => description}
        false
      rescue RestClient::BadRequest => e
        raise UnknownDeployStep, e.response
      end
    end

    def fail
      begin
        RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/complete", {:result => :failure}
        true
      rescue RestClient::Exception
        false
      end
    end

    def complete
      begin
        RestClient.post "#{deploy_monitor.base_url}/deploys/#{deploy_id}/complete", {:result => :failure}
        true
      rescue RestClient::Exception
        false
      end
    end
  end
end