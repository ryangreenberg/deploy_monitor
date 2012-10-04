module DeployMonitor
  class System
    include DeployMonitor::ApiObject
    include DeployMonitor::ApiErrors

    attr_accessor :client, :system_id, :name, :steps

    def self.from_api(client, api_obj)
      system = self.new
      system.client = client
      system.update_from_api(api_obj)
      system
    end

    def api_url
      "#{@client.base_url}/systems/#{name}"
    end

    def web_url
      "#{@client.web_url}/systems/#{name}"
    end

    def update_from_api(api_obj)
      self.system_id = api_obj['id']
      self.name = api_obj['name']
      self.steps = api_obj['steps'].map {|ea| Step.from_api(client, ea)}
    end

    def start_deploy
      begin
        rsp = RestClient.post("#{api_url}/deploys", {})
        deploy = Deploy.from_api(self.client, JSON.parse(rsp.body))
        deploy.system = self
        deploy
      rescue RestClient::BadRequest => e
        error = parse_error(e.response)
        raise error ? error.to_exception : e
      end
    end

    def current_deploy
      rsp = RestClient.get("#{api_url}/deploys", :params => {:active => true})
      deploys = JSON.parse(rsp.body)['deploys']
      if deploys.empty?
        nil
      else
        deploy = Deploy.from_api(self.client, deploys.first)
        deploy.system = self
        deploy
      end
    end
  end
end