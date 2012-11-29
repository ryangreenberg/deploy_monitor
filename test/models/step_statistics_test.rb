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

  describe "#completion_rate_for_step_id" do
    it "is the number of completions divided by the number of progresses" do
      steps = [
        TestStruct.new(:id => 2)
      ]
      progresses = [
        TestStruct.new(:step_id => 2, :complete? => true),
        TestStruct.new(:step_id => 2, :complete? => false)
      ]
      stats = StepStatistics.new(steps, progresses)
      assert_equal 0.5, stats.completion_rate_for_step_id(2)
    end

    it "is nil when there is no data for the step" do
      stats = StepStatistics.new([], [])
      assert_equal nil, stats.completion_rate_for_step_id(1)
    end
  end

  describe "#mean_duration_for_step_id" do
    it "is the average of the durations for the progresses for the step" do
      steps = [
        TestStruct.new(:id => 2)
      ]
      progresses = [
        TestStruct.new(:step_id => 2, :duration => 10, :complete? => true),
        TestStruct.new(:step_id => 2, :duration => 20, :complete? => true)
      ]
      stats = StepStatistics.new(steps, progresses)
      assert_equal 15, stats.mean_duration_for_step_id(2)
    end

    it "ignores progresses for other steps" do
      steps = [
        TestStruct.new(:id => 2)
      ]
      progresses = [
        TestStruct.new(:step_id => 2, :duration => 10, :complete? => true),
        TestStruct.new(:step_id => 3, :duration => 30, :complete? => true)
      ]
      stats = StepStatistics.new(steps, progresses)
      assert_equal 10, stats.mean_duration_for_step_id(2)
    end

    it "ignores progresses that are not complete" do
      steps = [
        TestStruct.new(:id => 2)
      ]
      progresses = [
        TestStruct.new(:step_id => 2, :duration => 10, :complete? => false),
        TestStruct.new(:step_id => 2, :duration => 40, :complete? => true)
      ]
      stats = StepStatistics.new(steps, progresses)
      assert_equal 40, stats.mean_duration_for_step_id(2)
    end

    it "is nil when there is no data for the step" do
      stats = StepStatistics.new([], [])
      assert_equal nil, stats.mean_duration_for_step_id(1)
    end
  end
end
