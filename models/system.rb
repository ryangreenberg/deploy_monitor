class System < Sequel::Model
  one_to_many :steps, :order => :number.asc
  one_to_many :deploys

  def active_deploy
    Deploy.filter(:system => self, :active => true).first
  end

  # Returns the next available number for a step associated with this system
  def next_step_number
    highest_existing_step = self.steps_dataset.order(:number.desc).limit(1).first
    highest_existing_step ? highest_existing_step.number : 0
  end

  def durations
    @durations ||= begin
      deploys = deploys_dataset.
        filter(:result => Models::RESULTS[:complete]).
        select(:started_at, :finished_at).
        all
      deploys.map {|ea| ea.finished_at - ea.started_at }
    end
  end

  def to_hash(options = {})
    hsh = values
    if options[:include_steps]
      hsh[:steps] = steps.map {|ea| ea.to_hash}
    end
    hsh
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end