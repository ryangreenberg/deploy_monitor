class System < Sequel::Model
  one_to_many :steps
  one_to_many :deploys

  def active_deploy
    Deploy.filter(:system => self, :active => true).first
  end

  # Returns the next available number for a step associated with this system
  def next_step_number
    highest_existing_step = self.steps.order(:number.desc).limit(1).first
    highest_existing_step ? highest_existing_step.number : 0
  end

  def to_hash(options = {})
    values
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end