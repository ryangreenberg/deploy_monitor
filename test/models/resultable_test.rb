require 'test/test_helper'
require 'models'

describe Resultable do
  before do
    klass = Class.new do
      include Resultable

      def active?
        false
      end

      def result
      end
    end
    @instance = klass.new
  end

  describe "#complete?" do
    it "is true when result returns RESULTS[:complete]" do
      @instance.stub(:result, Models::RESULTS[:complete]) do
        assert @instance.complete?
      end
    end

    it "is false when result returns anything except RESULTS[:complete]" do
      @instance.stub(:result, nil) do
        refute @instance.complete?
      end
    end
  end

  describe "#failed?" do
    it "is true when result returns RESULTS[:failed]" do
      @instance.stub(:result, Models::RESULTS[:failed]) do
        assert @instance.failed?
      end
    end

    it "is false when result returns anything except RESULTS[:failed]" do
      @instance.stub(:result, nil) do
        refute @instance.failed?
      end
    end
  end

  describe "#status_label" do
    it "is 'in progress' when the object is active" do
      @instance.stub(:active?, true) do
        assert_equal "in progress", @instance.status_label
      end
    end

    it "is :complete when the object is not active and result is RESULTS[:complete]" do
      @instance.stub(:result, Models::RESULTS[:complete]) do
        assert_equal :complete, @instance.status_label
      end
    end

    it "is :complete when the object is not active and result is RESULTS[:failed]" do
      @instance.stub(:result, Models::RESULTS[:failed]) do
        assert_equal :failed, @instance.status_label
      end
    end
  end
end
