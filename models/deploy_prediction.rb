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

  private

  def obvious_probability
    if @deploy.complete?
      1.0
    elsif @deploy.failed?
      0.0
    end
  end
end