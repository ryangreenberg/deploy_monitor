class StepStatistics
  def initialize(steps, progresses)
    @steps = @steps
    @progresses = progresses
  end

  def completion_rate_for_step(step)
    completion_rate_for_step_id(step.id)
  end

  def completion_rate_for_step_id(step_id)
    progresses_for_step = @progresses.select {|ea| ea.step_id == step_id}
    if progresses_for_step.empty?
      nil
    else
      completed = progresses_for_step.select {|ea| ea.complete? }
      completed.count.to_f / progresses_for_step.count
    end
  end

  def mean_duration_for_step_id(step_id)
    progresses_for_step = @progresses.select {|ea| ea.step_id == step_id }
    progresses_for_step.inject(0.0) {|sum, ea| sum + ea.duration } / progresses_for_step.size
  end

  def size
    @progresses.size
  end

  def empty?
    @progresses.empty?
  end
end