class DeployPrediction
  def initialize(deploy, progress_stats)
    @deploy = deploy
    @progress_stats = progress_stats
  end

  # The reasoning behind this method is that the probability of a deploy
  # completing successfully is the probability of all of its each steps
  # completing successfully
  def success_probability
    return obvious_probability unless @deploy.active?
    return 1.0 if @progress_stats.empty?

    relevant_steps = @deploy.remaining_steps

    success_rates = relevant_steps.map {|step| @progress_stats.step_success_rate(step.id) }
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