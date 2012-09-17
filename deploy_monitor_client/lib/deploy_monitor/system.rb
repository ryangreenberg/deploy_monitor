module DeployMonitor
  class System
    include DeployMonitor::ApiObject

    attr_accessor :client, :system_id, :name, :steps

    def self.from_api(client, api_obj)
      system = self.new
      system.client = client
      system.update_from_api(api_obj)
      system
    end

    def update_from_api(api_obj)
      self.system_id = api_obj['id']
      self.name = api_obj['name']
      self.steps = api_obj['steps'].map {|ea| Step.from_api(client, ea)}
    end

    def start_deploy
      begin
        rsp = RestClient.post("#{base_url}/#{name}/deploys", {})
        Deploy.from_api(self.client, JSON.parse(rsp.body))
      rescue RestClient::BadRequest => e
        raise e, e.response
      end
    end

    def current_deploy
      rsp = RestClient.get("#{base_url}/#{name}/deploys", :params => {:active => true})
      deploys = JSON.parse(rsp.body)['deploys']
      if deploys.empty?
        nil
      else
        Deploy.from_api(self.client, deploys.first)
      end
    end
  end
end