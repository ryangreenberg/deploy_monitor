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

  def progresses_from_recent_deploys(num_deploys_to_consider = 100)
    progresses = Progress.join(
      Deploy.filter(:system => self).order_by(:created_at.desc).limit(num_deploys_to_consider),
      :id => :deploy_id
    )
    completed_progresses = progresses.filter(:progresses__active => false)
    completed_progresses.select(
      :deploy_id,
      :progresses__id,
      :progresses__result,
      :progresses__step_id,
      :progresses__started_at,
      :progresses__finished_at
    )
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