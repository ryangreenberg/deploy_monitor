require 'test/test_helper'
require 'models'

describe System do
  before do
    @system = System.create(:name => 'frontend')
  end

  describe "#lock!" do
    it "makes a system locked" do
      refute @system.locked?
      @system.lock!
      assert @system.locked?
    end

    it "creates a new lock with the given description" do
      description = "There is an ongoing production incident."
      lock = @system.lock!(description)
      assert_equal description, lock.description
    end
  end
end
