class DeployPrediction
  def initialize(deploy, step_stats)
    @deploy = deploy
    @step_stats = step_stats
  end

  # The reasoning behind this method is that the probability of a deploy
  # completing successfully is the probability of all of its each steps
  # completing successfully
  def completion_probability
    return obvious_probability unless @deploy.active?
    return 1.0 if @step_stats.empty?

    relevant_steps = @deploy.remaining_steps

    success_rates = relevant_steps.map {|step| @step_stats.completion_rate_for_step_id(step.id) }
    success_rates.inject(1.0) {|accum, ea| accum * ea }
  end

  def completion_eta
    return @deploy.finished_at unless @deploy.active?

    future_steps = @deploy.future_steps
    durations = future_steps.map {|step| @step_stats.mean_duration_for_step_id(step.id) }
    future_steps_duration = durations.empty? ? 0 : durations.inject(:+)

    current_progress = @deploy.current_progress
    current_progress_duration = @step_stats.mean_duration_for_step_id(current_progress.step_id)
    current_progress_remaining = [
      0,
      current_progress_duration - (Time.now - current_progress.started_at)
    ].max

    Time.now + current_progress_remaining + future_steps_duration
  end

  private

  def obvious_probability
    if @deploy.complete?
      1.0
    elsif @deploy.failed?
      0.0
    end
  end
end