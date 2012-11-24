class ProgressStatistics
  def initialize(progresses)
    @progresses = progresses
  end

  def step_success_rate(step_id)
  end

  def size
    @progresses.size
  end

  def empty?
    @progresses.empty?
  end
end