require 'sequel/plugins/json_serializer'

class Deploy < Sequel::Model
  many_to_one :system
  one_to_many :progresses

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

  def current_progress
    Progress.filter(:deploy => self, :active => true).first
  end

  def at_step?(step)
    current_progress && current_progress.step == step
  end

  def progress_percentage
    if current_progress
      system.steps.index(current_progress.step) / system.steps.size.to_f * 100
    else
      0
    end
  end
end