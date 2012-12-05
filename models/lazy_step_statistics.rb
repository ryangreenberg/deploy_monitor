class LazyStepStatistics < StepStatistics
  # StepStatistics uses steps and progresses, which are lists of DB rows passed
  # in at the time of instantiation. This subclass accepts Sequel datasets
  # instead, which are queries that have not been executed.
  #
  # The first time `progresses` or `steps` are needed, those methods fetch
  # the rows from the dataset. This saves a lot of DB queries because non-active
  # deploys don't actually need this data.
  def initialize(steps_dataset, progresses_dataset)
    super
    @steps = nil
    @progresses = nil
    @steps_dataset = steps_dataset
    @progresses_dataset = progresses_dataset
  end

  def progresses
    @progresses ||= @progresses_dataset.all
  end

  def steps
    @steps ||= @steps_dataset.all
  end
end