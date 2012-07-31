class Deploy < Sequel::Model
  many_to_one :system
  one_to_many :progresses

  self.plugin :timestamps,
    :create => :created_at,
    :update => :updated_at,
    :update_on_create => true

  @json_serializer_opts = {:naked => true}
  self.plugin :json_serializer

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

  def to_hash(options = {})
    hsh = values.dup

    # Use integer timestamps
    [:created_at, :updated_at, :started_at, :finished_at].each do |ts_field|
      if hsh[ts_field]
        hsh[ts_field] = hsh[ts_field].to_i
      end
    end

    # Provide system object
    hsh.delete(:system_id)
    hsh[:system] = system.to_hash

    # Provide progress objects
    hsh[:progress] = progresses.map {|ea| ea.to_hash}

    # Provide metadata
    hsh[:metadata] = hsh[:metadata] ? JSON.parse(hsh[:metadata]) : {}

    hsh
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end