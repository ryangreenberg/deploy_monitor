class DatasetPagination
  def initialize(dataset, default_limit, max_limit)
    @dataset = dataset
    @default_limit = default_limit
    @max_limit = max_limit
  end

  def paged_dataset(user_limit = nil, user_offset = nil)
    limit = user_or_default_limit(user_limit)
    @dataset.limit(limit, user_offset)
  end

  private

  def user_or_default_limit(user_limit)
    if user_limit && user_limit.to_i > @max_limit
      @max_limit
    elsif user_limit
      user_limit
    else
      @default_limit
    end
  end
end