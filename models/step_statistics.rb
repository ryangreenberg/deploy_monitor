class StepStatistics
  def initialize(steps, progresses)
    @steps = @steps
    @progresses = progresses
  end

  def completion_rate_for_step(step)
    completion_rate_for_step_id(step.id)
  end

  def completion_rate_for_step_id(step_id)
    with_completed_progresses(step_id) do |progresses, completed|
      completed.count.to_f / progresses.count
    end
  end

  def mean_duration_for_step_id(step_id)
    with_completed_progresses(step_id) do |progresses, completed|
      completed.inject(0.0) {|sum, ea| sum + ea.duration } / completed.count
    end
  end

  def size
    @progresses.size
  end

  def empty?
    @progresses.empty?
  end

  private

  def with_completed_progresses(step_id)
    progresses_for_step = @progresses.select {|ea| ea.step_id == step_id }
    if progresses_for_step.empty?
      nil
    else
      completed_progresses = progresses_for_step.select {|ea| ea.complete? }
      yield(progresses_for_step, completed_progresses)
    end
  end
end