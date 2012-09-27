module DeployMonitor
  class Client
    def initialize(host)
      @host = URI.parse(host)
    end

    def all_systems
      begin
        rsp = RestClient.get "#{base_url}/systems"
        systems = JSON.parse(rsp.body)["systems"]
        systems.map {|ea| System.from_api(self, ea)}
      rescue RestClient::ResourceNotFound => e
        nil
      end
    end

    def find_system_by_name(name)
      begin
        rsp = RestClient.get "#{base_url}/systems/#{name}"
        System.from_api(self, JSON.parse(rsp.body))
      rescue RestClient::ResourceNotFound => e
        nil
      end
    end

    def create_system(name)
      RestClient.post "#{base_url}/systems", {:name => name}
    end

    def find_deploy_by_id(id)
      begin
        rsp = RestClient.get "#{base_url}/deploys/#{id}"
        Deploy.from_api(self, JSON.parse(rsp.body))
      rescue RestClient::ResourceNotFound => e
        nil
      end
    end

    def base_url
      "#{@host}/api"
    end
  end
end