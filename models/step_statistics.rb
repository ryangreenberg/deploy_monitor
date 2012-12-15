class StepStatistics
  attr_reader :steps, :progresses

  def initialize(steps, progresses)
    @steps = steps
    @progresses = progresses

    # Memoization
    @completion_rates = {}
    @mean_durations = {}
    @median_durations = {}
  end

  def completion_rate_for_step(step)
    completion_rate_for_step_id(step.id)
  end

  def completion_rate_for_step_id(step_id)
    @completion_rates[step_id] ||= begin
        with_completed_progresses(step_id) do |progresses, completed|
        completed.count.to_f / progresses.count
      end
    end
  end

  def mean_duration_for_step(step)
    mean_duration_for_step_id(step.id)
  end

  def mean_duration_for_step_id(step_id)
    @mean_durations[step_id] ||= begin
      with_completed_progresses(step_id) do |progresses, completed|
        stats = DescriptiveStatistics.new(completed.map {|ea| ea.duration})
        stats.mean
      end
    end
  end

  def median_duration_for_step(step)
    median_duration_for_step_id(step.id)
  end

  def median_duration_for_step_id(step_id)
    @median_durations[step_id] ||= begin
      with_completed_progresses(step_id) do |progresses, completed|
        stats = DescriptiveStatistics.new(completed.map {|ea| ea.duration})
        stats.median
      end
    end
  end

  def size
    progresses.size
  end

  def empty?
    progresses.empty?
  end

  private

  def with_completed_progresses(step_id)
    progresses_for_step = progresses.select {|ea| ea.step_id == step_id }
    if progresses_for_step.empty?
      nil
    else
      completed_progresses = progresses_for_step.select {|ea| ea.complete? }
      yield(progresses_for_step, completed_progresses)
    end
  end
end