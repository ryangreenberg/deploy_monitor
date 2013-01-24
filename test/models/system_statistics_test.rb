require 'test/test_helper'
require 'models'

describe SystemStatistics do
  describe "avg_duration" do
    it "is 0 when no durations are available" do
      sys = System.new(:name => "test system")
      stub(sys).durations { [] }
      stats = SystemStatistics.new(sys)
      assert_equal 0, stats.avg_duration
    end
  end

  describe "median_duration" do
    it "is 0 when no durations are available" do
      sys = System.new(:name => "test system")
      stub(sys).durations { [] }
      stats = SystemStatistics.new(sys)
      assert_equal 0, stats.median_duration
    end
  end
end
