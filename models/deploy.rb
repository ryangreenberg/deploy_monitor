require 'sequel/plugins/json_serializer'

class Deploy < Sequel::Model
  many_to_one :system
  one_to_many :steps

  self.plugin :timestamps,
    :create => :created_at,
    :update => :updated_at,
    :update_on_create => true

  @json_serializer_opts = {:naked => true}
  self.plugin :json_serializer

  RESULTS = {
    :complete => 0,
    :failed => 1,
    :abandoned => 2
  }

  def self.active
    filter { {:active => true} }
  end

  def active_step
    Step.filter(:deploy => self, :active => true).first
  end

  def current_step?(step)
    active_step && active_step.deploy_step == step
  end

  def progress_percentage
    if active_step
      system.deploy_steps.index(active_step.deploy_step) / system.deploy_steps.size.to_f * 100
    else
      0
    end
  end
end