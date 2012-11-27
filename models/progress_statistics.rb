class ProgressStatistics
  def initialize(progresses)
    @progresses = progresses
  end

  def step_success_rate(step_id)
    progresses_for_step = @progresses.select {|ea| ea.step_id == step_id}
    if progresses_for_step.empty?
      nil
    else
      completed = progresses_for_step.select {|ea| ea.complete? }
      completed.count.to_f / progresses_for_step.count
    end
  end

  def size
    @progresses.size
  end

  def empty?
    @progresses.empty?
  end
end