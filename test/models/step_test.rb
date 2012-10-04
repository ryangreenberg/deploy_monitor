require 'test/test_helper'
require 'models'

describe Step do
  before do
    @system = System.create(:name => 'frontend')
  end

  describe "#renumber_overlapping_steps" do
    it "it adjusts the system steps that are greater than the provided number" do
      first = Step.create(:name => "first", :system => @system, :number => 1)
      second = Step.create(:name => "second", :system => @system, :number => 2)
      Step.renumber_overlapping_steps(@system, 1)
      assert_equal 2, first.reload.number
      assert_equal 3, second.reload.number
    end
  end
end
