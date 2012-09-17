module DeployMonitor
  class System
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
  end
end