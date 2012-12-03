require 'test/test_helper'
require 'models'

describe StatisticsHelpers do
  describe ".with_minimum_value" do
    it "adjusts all values in the collection to be at least the provided value" do
      arr = [0, 0, 10]
      min_val = 1
      adjusted_arr = StatisticsHelpers.with_minimum_value(arr, min_val)
      assert adjusted_arr.all? {|ea| ea >= min_val }
    end

    it "maintains the total sum of the values in the collection" do
      arr = [0, 0, 10]
      adjusted_arr = StatisticsHelpers.with_minimum_value(arr, 1)
      initial_sum = arr.inject(:+)
      adjusted_sum = adjusted_arr.inject(:+)
      assert_equal initial_sum, adjusted_sum
    end

    it "raises an error if maintaining the total sum is impossible for the given minimum value" do
      arr = [0, 0, 10]
      assert_raises(ArgumentError) { StatisticsHelpers.with_minimum_value(arr, 5) }
    end

    it "does not adjust any elements below the minimum value" do
      arr = [0, 1.1, 8.9]
      min_val = 1
      adjusted_arr = StatisticsHelpers.with_minimum_value(arr, min_val)
      assert adjusted_arr.all? {|ea| ea >= min_val }
    end
  end
end
