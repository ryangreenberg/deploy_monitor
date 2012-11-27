require 'test/test_helper'
require 'models'

describe StepStatistics do
  describe "#empty?" do
    it "is true when initialized with no progresses" do
      steps = [TestStruct.new]
      progresses = []
      assert StepStatistics.new(steps, progresses).empty?
    end

    it "is false when initialized with progresses" do
      steps = [TestStruct.new]
      progresses = [TestStruct.new]
      refute StepStatistics.new(steps, progresses).empty?
    end
  end

  describe "#step_success_rate" do
    it "is the number of completions divided by the number of progresses" do
      steps = [
        TestStruct.new(:id => 2)
      ]
      progresses = [
        TestStruct.new(:step_id => 2, :complete? => true),
        TestStruct.new(:step_id => 2, :complete? => false)
      ]
      stats = StepStatistics.new(steps, progresses)
      assert_equal 0.5, stats.step_success_rate(2)
    end

    it "is nil when there is no data for the progresses" do
      stats = StepStatistics.new([], [])
      assert_equal nil, stats.step_success_rate(1)
    end
  end
end
