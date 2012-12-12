require 'json'

class Deploy < Sequel::Model
  include Resultable

  many_to_one :system
  one_to_many :progresses

  self.plugin :timestamps,
    :create => :created_at,
    :update => :updated_at,
    :update_on_create => true

  def self.active
    filter { {:active => true} }
  end

  def active?
    active
  end

  def duration
    if started_at && finished_at
      finished_at - started_at
    elsif started_at
      Time.now - started_at
    else
      nil
    end
  end

  module Prediction
    def prediction
      @prediction ||= begin
        progresses = system.progresses_from_recent_deploys(Models::DEFAULT_DEPLOY_STATS_WINDOW)
        stats = LazyStepStatistics.new(system.steps_dataset, progresses)
        DeployPrediction.new(self, stats)
      end
    end

    def completion_probability
      prediction.completion_probability
    end

    def completion_eta
      prediction.completion_eta
    end

    def completion_eta_bounds
      prediction.completion_time_bounds
    end
  end
  include Prediction

  module Steps
    def current_step
      if active && cur_progress = current_progress
        cur_progress.step
      else
        nil
      end
    end

    # Get steps after the last progress for this deploy
    def future_steps
      if active
        Step.filter(:system => system).where{ |o| o.number >= next_step_number}.order(:number.asc)
      else
        []
      end
    end

    # TODO: Can be rewritten as a single query:
    # SELECT * FROM steps WHERE number >= (current step number subselect)
    def remaining_steps
      ([ current_step ] + future_steps.map {|ea| ea}).compact
    end

    # Returns the number of the current progress associated with this deploy + 1
    def next_step_number
      progress = current_progress
      progress ? current_progress.step.number + 1 : 0
    end

    def current_progress
      Progress.filter(:deploy => self, :active => true).first
    end

    def at_step?(step)
      current_progress && current_progress.step == step
    end

    def progress_percentage
      if active
        if current_progress
          system.steps.index(current_progress.step) / system.steps.size.to_f * 100
        else
          0
        end
      end
    end
  end
  include Steps

  module Metadata
    def metadata
      @metadata ||= load_metadata_from_db
    end

    def has_metadata?
      !metadata.empty?
    end

    def load_metadata_from_db
      return {} unless values[:metadata]
      begin
        JSON.parse(values[:metadata])
      rescue JSON::ParserError => e
        {}
      end
    end

    def mark_metadata_as_changed
      changed_columns << :metadata unless changed_columns.include?(:metadata)
    end

    def set_metadata(key, value)
      mark_metadata_as_changed
      metadata[key.to_s] = value
    end

    def remove_metadata(key)
      mark_metadata_as_changed
      metadata.delete(key.to_s)
    end

    def get_metadata(key)
      metadata[key.to_s]
    end

    def multiset_metadata(hsh)
      hsh.each do |key, value|
        if value.strip.empty?
          remove_metadata(key)
        else
          set_metadata(key, value)
        end
      end
    end

    def before_save
      super
      if changed_columns.include?(:metadata)
        values[:metadata] = JSON.dump(@metadata)
      end
    end
  end
  include Metadata

  module Representation
    def to_hash(options = {})
      hsh = values.dup

      # Use integer timestamps
      [:created_at, :updated_at, :started_at, :finished_at].each do |ts_field|
        if hsh[ts_field]
          hsh[ts_field] = hsh[ts_field].to_i
        end
      end

      # Convert result enum to named value
      if hsh[:result]
        hsh[:result] = Models::RESULTS.invert[hsh[:result]]
      end

      # Provide system object
      hsh.delete(:system_id)
      hsh[:system] = system.to_hash

      # Provide progress objects
      hsh[:progress] = progresses.map {|ea| ea.to_hash}

      # Provide metadata
      hsh[:metadata] = metadata

      # Predictions
      hsh[:completion_probability] = completion_probability
      hsh[:predicted_finished_at] = completion_eta.to_i
      lower_bound, upper_bound = completion_eta_bounds
      hsh[:predicted_finished_at_lower_bound] = lower_bound.to_i
      hsh[:predicted_finished_at_upper_bound] = upper_bound.to_i

      hsh
    end

    def to_json(options = {})
      to_hash(options).to_json
    end
  end
  include Representation
end