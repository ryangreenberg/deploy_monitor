module DeployMonitor
  class Deploy

    class UnknownDeployStep < ArgumentError; end
    TIMESTAMPS = [:created_at, :updated_at, :started_at, :finished_at]

    attr_accessor :client, :system
    attr_reader :active, :progress, :metadata, *TIMESTAMPS

    def self.from_api(client, api_obj)
      deploy = self.new
      deploy.client = client
      deploy.update_from_api(api_obj)
      deploy
    end

    def update_from_api(api_obj)
      @deploy_id = api_obj['id']
      @active = api_obj['active']
      @progress = api_obj['progress']
      @metadata = api_obj['metadata']

      @created_at = api_obj['created_at'] ? Time.at(api_obj['created_at']) : nil
      @updated_at = api_obj['updated_at'] ? Time.at(api_obj['updated_at']) : nil
      @started_at = api_obj['started_at'] ? Time.at(api_obj['started_at']) : nil
      @finished_at = api_obj['finished_at'] ? Time.at(api_obj['finished_at']) : nil
    end

    def update_from_json(json)
      begin
        api_obj = JSON.parse(json)
        update_from_api(api_obj)
      rescue JSON::ParserError => e
      end
    end

    def refresh_self
      update_from_json(RestClient.get("#{@client.base_url}/deploys/#{@deploy_id}"))
    end

    def progress_to(step, description = nil)
      begin
        RestClient.post("#{@client.base_url}/deploys/#{@deploy_id}/step/#{step}",
          {:description => description})
        refresh_self
        true
      rescue RestClient::BadRequest => e
        raise UnknownDeployStep, e.response
      end
    end

    # Updates deploy to associate all keys in +hsh+ with the provided values.
    # If you want to delete a key, set its value to nil.
    def update_metadata(hsh)
      begin
        rsp = RestClient.put("#{@client.base_url}/deploys/#{@deploy_id}", hsh)
        update_from_json(rsp)
        true
      rescue RestClient::Exception
        false
      end
    end

    def fail
      begin
        rsp = RestClient.post("#{@client.base_url}/deploys/#{@deploy_id}/complete",
          {:result => :failed})
        update_from_json(rsp)
        true
      rescue RestClient::Exception
        false
      end
    end

    def complete
      begin
        rsp = RestClient.post("#{@client.base_url}/deploys/#{@deploy_id}/complete", {})
        update_from_json(rsp)
        true
      rescue RestClient::Exception
        false
      end
    end
  end
end