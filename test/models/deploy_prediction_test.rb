require 'test/test_helper'
require 'models'

describe DeployPrediction do
  describe "#completion_probability" do
    before(:each) do
      @deploy = Deploy.new(
        :active => true
      )
      stub(@deploy).current_step { TestStruct.new(:id => 2) }
      stub(@deploy).future_steps { [TestStruct.new(:id => 3), TestStruct.new(:id => 4)] }
      @failed_progress = TestStruct.new(:failed? => true, :deploy_id => 1)

      @progress_stats = ProgressStatistics.new([])
      stub(@progress_stats).empty? { false }
    end

    it "is 100% for non-active deploys that completed" do
      stub(@deploy).active { false }
      stub(@deploy).complete? { true }
      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 1.0, prediction.completion_probability
    end

    it "is 0% for non-active deploys that failed" do
      stub(@deploy).active  { false }
      stub(@deploy).failed? { true }
      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 0.0, prediction.completion_probability
    end

    it "optimistically assumes 100% if no data is available" do
      stub(@progress_stats).empty? { true }
      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 1.0, prediction.completion_probability
    end

    it "is the joint probability of each step completing successfully" do
      # ASCII intuition guide, provided to demonstrate the expected
      # 25% probability of completion given these 4 deploys
      # - x
      # - x
      # - - x
      # - - -
      stub(@progress_stats).step_success_rate(1) { 1.0 }
      stub(@progress_stats).step_success_rate(2) { 0.5 }
      stub(@progress_stats).step_success_rate(3) { 0.5 }
      stub(@deploy).remaining_steps do
        [ TestStruct.new(:id => 1), TestStruct.new(:id => 2), TestStruct.new(:id => 3) ]
      end

      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 0.25, prediction.completion_probability
    end

    it "ignores failures that occurred before the deploy's current step" do
      stub(@progress_stats).step_success_rate(1) { 0.25 }
      stub(@progress_stats).step_success_rate(2) { 0.50 }
      stub(@deploy).remaining_steps { [ TestStruct.new(:id => 2) ] }

      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 0.50, prediction.completion_probability
    end
  end
end
