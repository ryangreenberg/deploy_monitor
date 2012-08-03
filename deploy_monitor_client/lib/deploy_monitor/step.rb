module DeployMonitor
  class Step
    attr_accessor :deploy_monitor, :step_id, :name, :description, :number

    def self.from_api(deploy_monitor, api_obj)
      step = self.new
      step.deploy_monitor = deploy_monitor
      step.update_from_api(api_obj)
      step
    end

    def update_from_api(api_obj)
      self.step_id = api_obj['id']
      self.name = api_obj['name']
      self.description = api_obj['description']
      self.number = api_obj['number'] ? api_obj['number'].to_i : nil
    end
  end
end