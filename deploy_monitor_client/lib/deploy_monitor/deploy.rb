module DeployMonitor
  class Deploy
    include DeployMonitor::ApiObject
    include DeployMonitor::ApiErrors

    TIMESTAMPS = [
      :created_at,
      :updated_at,
      :started_at,
      :finished_at,
      :predicted_finished_at
    ]

    attr_accessor :client, :system
    attr_reader :deploy_id, :active, :progress, :metadata,
      :completion_probability, *TIMESTAMPS

    def self.from_api(client, api_obj)
      deploy = self.new
      deploy.client = client
      deploy.update_from_api(api_obj)
      deploy
    end

    def api_url
      "#{@client.base_url}/deploys/#{deploy_id}"
    end

    def web_url
      "#{@client.web_url}/deploys/#{deploy_id}"
    end

    def update_from_api(api_obj)
      @deploy_id = api_obj['id']
      @active = api_obj['active']
      @progress = api_obj['progress']
      @metadata = api_obj['metadata']
      @completion_probability = api_obj['completion_probability']

      @created_at = time_or_nil(api_obj['created_at'])
      @updated_at = time_or_nil(api_obj['updated_at'])
      @started_at = time_or_nil(api_obj['started_at'])
      @finished_at = time_or_nil(api_obj['finished_at'])
      @predicted_finished_at = time_or_nil(api_obj['predicted_finished_at'])
    end

    def update_from_json(json)
      begin
        api_obj = JSON.parse(json)
        update_from_api(api_obj)
      rescue JSON::ParserError => e
      end
    end

    def refresh_self
      update_from_json(RestClient.get(api_url))
    end

    def progress_to(step)
      begin
        RestClient.post("#{api_url}/step/#{step}", {})
        refresh_self
        true
      rescue RestClient::BadRequest => e
        error = parse_error(e.response)
        raise error ? error.to_exception : e
      end
    end

    def steps
      # This will raise NoMethodError if deploy was loaded via Client#find_by_id
      system.steps
    end

    # Updates deploy to associate all keys in +hsh+ with the provided values.
    # If you want to delete a key, set its value to nil.
    def update_metadata(hsh)
      begin
        rsp = RestClient.put(api_url, hsh)
        update_from_json(rsp)
        true
      rescue RestClient::Exception
        false
      end
    end

    def fail!
      begin
        rsp = RestClient.post("#{api_url}/complete", {:result => :failed})
        update_from_json(rsp)
        true
      rescue RestClient::Exception
        false
      end
    end

    def complete!
      begin
        rsp = RestClient.post("#{api_url}/complete", {})
        update_from_json(rsp)
        true
      rescue RestClient::Exception
        false
      end
    end

    private

    def time_or_nil(val)
      val ? Time.at(val) : nil
    end
  end
end