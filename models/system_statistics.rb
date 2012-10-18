class SystemStatistics
  def initialize(sys)
    @sys = sys
  end

  def result_statistics
    @results_stats ||= begin
      Models::RESULTS.inject({}) do |hsh, (k, v)|
        hsh[k] = @sys.deploys_dataset.filter(:result => v).count
        hsh
      end
    end
  end

  def num_complete_deploys
    result_statistics[:complete]
  end

  def num_failed_deploys
    result_statistics[:failed]
  end

  def durations
    @sys.durations
  end

  def avg_duration
    durations.inject(0) {|sum, ea| sum + ea } / durations.size.to_f
  end

  def median_duration
    sorted_durations = durations.sort
    count = sorted_durations.count
    if count.odd?
      sorted_durations[count / 2]
    else
      (sorted_durations[count / 2 - 1] + sorted_durations[count / 2]) / 2
    end
  end
end