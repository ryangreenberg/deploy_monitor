class SqlStepStatistics < StepStatistics
  def initialize(steps_dataset, progresses_dataset)
    @steps = steps_dataset
    @progresses = progresses_dataset

    @mean_durations = nil
    @std_dev_durations = nil
    @progress_completions = nil
    @progress_counts = nil
  end

  def completion_rate_for_step_id(step_id)
    progress_completions[step_id].to_f / progress_counts[step_id]
  end

  def mean_duration_for_step_id(step_id)
    mean_durations[step_id]
  end

  def std_dev_duration_for_step_id(step_id)
    std_dev_durations[step_id]
  end

  def median_duration_for_step_id(step_id)
    raise NotImplementedError, "SqlStepStatistics does not support median calculations"
  end

  def size
    progresses.count
  end

  def empty?
    progresses.empty?
  end

  private

  def mean_durations
    fetch_duration_stats unless @mean_durations
    @mean_durations
  end

  def std_dev_durations
    fetch_duration_stats unless @std_dev_durations
    @std_dev_durations
  end

  def progress_counts
    fetch_completion_stats unless @progress_counts
    @progress_counts
  end

  def progress_completions
    fetch_completion_stats unless @progress_completions
    @progress_completions
  end

  def fetch_completion_stats
    progress_completions = progresses.select(
      :step_id,
      Sequel.lit("COUNT(*)").as("count")
    ).filter(:progresses__result => Models::RESULTS[:complete]).group_by(:step_id)

    progress_counts = progresses.select(
      :step_id,
      Sequel.lit("COUNT(*)").as("count")
    ).group_by(:step_id)

    @progress_counts = Hash[ progress_counts.map {|ea| [ea[:step_id], ea[:count]] } ]
    @progress_completions = Hash[ progress_completions.map {|ea| [ea[:step_id], ea[:count]] } ]
  end

  def fetch_duration_stats
    timestampdiff = Sequel.function(:TIMESTAMPDIFF, Sequel.lit("SECOND"), :progresses__started_at, :progresses__finished_at)
    stats_dataset = progresses.select(
      :step_id,
      Sequel.function(:AVG, timestampdiff).as(:avg),
      Sequel.function(:STDDEV_POP, timestampdiff).as(:std_dev)
    ).filter(:progresses__result => Models::RESULTS[:complete]).group_by(:step_id)

    db_stats = stats_dataset.inject({}) do |hsh, ea|
      hsh[ea[:step_id]] = {
        :avg => ea[:avg].to_f,
        :std_dev => ea [:std_dev].to_f
      }
      hsh
    end

    @mean_durations = Hash[ db_stats.map {|step_id, stats| [step_id, stats[:avg]] } ]
    @std_dev_durations = Hash[ db_stats.map {|step_id, stats| [step_id, stats[:std_dev]] } ]
  end
end