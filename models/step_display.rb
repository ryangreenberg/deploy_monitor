class StepDisplay
  include Enumerable

  attr_reader :steps, :stats

  def initialize(steps, stats)
    @steps = steps
    @stats = stats
  end

  def build_collection_stats
    @step_durations = steps.map {|ea| stats.mean_duration_for_step(ea).round }
    @step_completion_rate = steps.map {|ea| stats.completion_rate_for_step(ea) }
    total_duration = @step_durations.inject(:+)
    @raw_duration_percentage = @step_durations.map {|ea| ea.to_f / total_duration * 100 }
    @distorted_percentage = StatisticsHelpers.with_minimum_value(@raw_duration_percentage, 0.5)
  end

  def each
    build_collection_stats unless stats_built?
    steps.each_with_index do |ea, idx|
      details = {
        :duration => @step_durations[idx],
        :raw_duration_percentage => @raw_duration_percentage[idx],
        :distorted_duration_percentage => @distorted_percentage[idx],
        :completion_rate => @step_completion_rate[idx]
      }
      yield ea, details
    end
  end

  private

  def stats_built?
    !(@step_durations.nil? ||
    @step_completion_rate.nil? ||
    @raw_duration_percentage.nil? ||
    @distorted_percentage.nil?)
  end
end