require 'json'

class Deploy < Sequel::Model
  many_to_one :system
  one_to_many :progresses

  self.plugin :timestamps,
    :create => :created_at,
    :update => :updated_at,
    :update_on_create => true

  def self.active
    filter { {:active => true} }
  end

  module Result
    def complete?
      result == Models::RESULTS[:complete]
    end

    def failed?
      result == Models::RESULTS[:failed]
    end

    def status_label
      if active
        'in progress'
      else
        Models::RESULTS.invert[result]
      end
    end
  end
  include Result

  module Steps
    # Get steps after the last progress for this deploy
    def future_steps
      if active
        Step.filter(:system => system).where{ |o| o.number >= next_step_number}.order(:number.asc)
      else
        []
      end
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

  def duration
    if started_at && finished_at
      finished_at - started_at
    elsif started_at
      Time.now - started_at
    else
      nil
    end
  end

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

      hsh
    end

    def to_json(options = {})
      to_hash(options).to_json
    end
  end
  include Representation
end