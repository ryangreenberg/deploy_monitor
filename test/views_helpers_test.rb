require 'test/test_helper'

describe ViewsHelpers do
  before(:each) do
    klass = Class.new do
      include ViewsHelpers
    end
    @instance = klass.new
  end

  describe "#format_percent" do
    it "multiplies the value by 100" do
      assert_equal 95.0, @instance.format_percent(0.95)
    end

    it "strips the trailing .0" do
      assert_equal "95", @instance.format_percent(0.95).to_s
    end

    it "includes the specified number of digits after the decimal" do
      assert_equal "12.3", @instance.format_percent(0.123, 1).to_s
    end
  end

  describe "#color_for_completion_rate" do
    it "rounds to a nearby segment" do
      assert_equal "bar-92", @instance.color_for_completion_rate(0.94)
    end

    it "uses 70 as a lower bound" do
      assert_equal "bar-70", @instance.color_for_completion_rate(0.60)
    end
  end
end