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

      @progress_stats = StepStatistics.new([], [])
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
      stub(@progress_stats).completion_rate_for_step_id(1) { 1.0 }
      stub(@progress_stats).completion_rate_for_step_id(2) { 0.5 }
      stub(@progress_stats).completion_rate_for_step_id(3) { 0.5 }
      stub(@deploy).remaining_steps do
        [ TestStruct.new(:id => 1), TestStruct.new(:id => 2), TestStruct.new(:id => 3) ]
      end

      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 0.25, prediction.completion_probability
    end

    it "ignores failures that occurred before the deploy's current step" do
      stub(@progress_stats).completion_rate_for_step_id(1) { 0.25 }
      stub(@progress_stats).completion_rate_for_step_id(2) { 0.50 }
      stub(@deploy).remaining_steps { [ TestStruct.new(:id => 2) ] }

      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal 0.50, prediction.completion_probability
    end
  end

  describe "#completion_eta" do
    before(:each) do
      @deploy = Deploy.new(
        :active => true
      )
      stub(@deploy).current_step { TestStruct.new(:id => 2) }
      stub(@deploy).future_steps { [TestStruct.new(:id => 3), TestStruct.new(:id => 4)] }
      @failed_progress = TestStruct.new(:failed? => true, :deploy_id => 1)

      @progress_stats = StepStatistics.new([], [])
      stub(@progress_stats).empty? { false }
    end

    it "is the deploy finished_at time for non-active deploys" do
      past_time = Time.now - 10
      stub(@deploy).active { false }
      stub(@deploy).finished_at { past_time }
      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal past_time, prediction.completion_eta
    end

    it "is at least the sum of the mean duration for the future steps" do
      Timecop.freeze do
        stub(@deploy).current_progress { TestStruct.new(:step_id => 2, :started_at => Time.now) }
        stub(@progress_stats).mean_duration_for_step_id(2) { 0 }
        stub(@progress_stats).mean_duration_for_step_id(3) { 30 }
        stub(@progress_stats).mean_duration_for_step_id(4) { 40 }

        prediction = DeployPrediction.new(@deploy, @progress_stats)
        assert_equal 70, (prediction.completion_eta - Time.now)
      end
    end

    it "includes the current step" do
      Timecop.freeze do
        progress_start_time = Time.now
        stub(@deploy).future_steps { [] }
        stub(@deploy).current_progress { TestStruct.new(:step_id => 2, :started_at => progress_start_time) }
        stub(@progress_stats).mean_duration_for_step_id(2) { 10 }

        prediction = DeployPrediction.new(@deploy, @progress_stats)
        assert_equal Time.now + 10, prediction.completion_eta
      end
    end

    it "discounts the elapsed portion of the current step" do
      Timecop.freeze do
        progress_start_time = Time.now - 5
        stub(@deploy).future_steps { [] }
        stub(@deploy).current_progress { TestStruct.new(:step_id => 2, :started_at => progress_start_time) }
        stub(@progress_stats).mean_duration_for_step_id(2) { 10 }

        prediction = DeployPrediction.new(@deploy, @progress_stats)
        assert_equal Time.now + 5, prediction.completion_eta
      end
    end

    it "does not give an estimate in the past if a step is running long" do
      Timecop.freeze do
        progress_start_time = Time.now - 20
        stub(@deploy).future_steps { [] }
        stub(@deploy).current_progress { TestStruct.new(:step_id => 2, :started_at => progress_start_time) }
        stub(@progress_stats).mean_duration_for_step_id(2) { 10 }

        prediction = DeployPrediction.new(@deploy, @progress_stats)
        assert_equal Time.now, prediction.completion_eta
      end
    end
  end

  describe "#completion_time_bounds" do
    before(:each) do
      @deploy = Deploy.new(
        :active => true
      )
      stub(@deploy).remaining_steps do
        [
          TestStruct.new(:id => 2),
          TestStruct.new(:id => 3),
          TestStruct.new(:id => 4)
        ]
      end
      @progress_stats = StepStatistics.new([], [])
      stub(@progress_stats).empty? { false }
    end

    it "is the deploy finished_at time for non-active deploys" do
      past_time = Time.now - 10
      stub(@deploy).active { false }
      stub(@deploy).finished_at { past_time }
      prediction = DeployPrediction.new(@deploy, @progress_stats)
      assert_equal [past_time, past_time], prediction.completion_time_bounds(past_time)
    end

    it "uses the standard deviation of the remaining steps to add bounds to completion_eta" do
      Timecop.freeze do
        stub(@progress_stats).std_dev_duration_for_step_id(2) { 10 }
        stub(@progress_stats).std_dev_duration_for_step_id(3) { 20 }
        stub(@progress_stats).std_dev_duration_for_step_id(4) { 30 }

        prediction = DeployPrediction.new(@deploy, @progress_stats)
        eta = Time.now + 120
        assert_equal [eta - 60, eta + 60], prediction.completion_time_bounds(eta)
      end
    end

    it "does not provide lower bounds less than the current time" do
      Timecop.freeze do
        stub(@progress_stats).std_dev_duration_for_step_id(2) { 10 }
        stub(@progress_stats).std_dev_duration_for_step_id(3) { 20 }
        stub(@progress_stats).std_dev_duration_for_step_id(4) { 30 }

        prediction = DeployPrediction.new(@deploy, @progress_stats)
        eta = Time.now
        assert_equal [eta, eta + 60], prediction.completion_time_bounds(eta)
      end
    end
  end
end
