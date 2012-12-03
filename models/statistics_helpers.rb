class StatisticsHelpers
  # Returns a collection where all elements are at least the provided minimum
  # value without changing the sum of the elements. This is useful if you want
  # to exaggerate some elements of a progress bar without changing the
  # total width
  def self.with_minimum_value(arr, min_val)
    initial_sum = arr.inject(:+)
    if min_val * arr.count > initial_sum
      raise ArgumentError, "Cannot maintain initial sum #{initial_sum} and set all elements to a minimum value #{min_val}"
    end

    below_min, above_min = arr.partition {|ea| ea < min_val}
    total_increase = below_min.inject(0.0) {|accum, i| accum + (min_val - i)}
    total_available = above_min.map {|ea| ea - min_val }.inject(:+)

    arr_with_min_vals = arr.map do |ea|
      if ea < min_val
        min_val
      else
        proportion_of_sum_above_min_val = (ea - min_val).to_f / total_available
        ea - proportion_of_sum_above_min_val * total_increase
      end
    end

    arr_with_min_vals
  end
end