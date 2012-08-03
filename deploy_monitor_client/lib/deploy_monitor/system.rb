module DeployMonitor
  class System
    attr_accessor :deploy_monitor, :system_id, :name

    def self.from_api(deploy_monitor, api_obj)
      system = self.new
      system.deploy_monitor = deploy_monitor
      system.update_from_api(api_obj)
      system
    end

    def update_from_api(api_obj)
      self.system_id = api_obj['id']
      self.name = api_obj['name']
    end
  end
end