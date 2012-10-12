class SystemStatistics
  def initialize(sys)
    @sys = sys
  end

  def result_statistics
    Models::RESULTS.inject({}) do |hsh, (k, v)|
      hsh[k] = @sys.deploys_dataset.filter(:result => v).count
      hsh
    end
  end
end