module DeployMonitor
  class Client
    def initialize(host)
      @host = URI.parse(host)
    end

    def get_system(name)
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

    def start_deploy(system)
      begin
        rsp = RestClient.post "#{base_url}/#{system}/deploys", {}
        Deploy.from_api(self, JSON.parse(rsp.body))
      rescue RestClient::BadRequest => e
        raise e, e.response
      end
    end

    def current_deploy(system)
      rsp = RestClient.get "#{base_url}/#{system}/deploys", :params => {:active => true}
      deploys = JSON.parse(rsp.body)['deploys']
      if deploys.empty?
        nil
      else
        Deploy.from_api(self, deploys.first)
      end
    end

    def get_deploy(id)
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