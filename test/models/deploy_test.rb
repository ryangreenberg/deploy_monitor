require 'test/test_helper'
require 'models'

describe Deploy do
  before do
    @system = System.create(:name => 'frontend')
    @default_attrs = {
      :system => @system,
      :active => true
    }
  end

  describe "Representation" do
    describe "#to_hash" do
      it "converts times to timestamps" do
        now = Time.now
        now_timestamp = now.to_i
        deploy = Deploy.create(@default_attrs.merge({
          :created_at => now,
          :updated_at => now,
          :started_at => now,
          :finished_at => now
        }))
        stub(deploy).completion_eta { Time.now }
        stub(deploy).completion_eta_bounds { [Time.now, Time.now] }
        hsh = deploy.to_hash
        assert_equal now_timestamp, hsh[:created_at]
        assert_equal now_timestamp, hsh[:updated_at]
        assert_equal now_timestamp, hsh[:started_at]
        assert_equal now_timestamp, hsh[:finished_at]
      end

      it "includes the completion probability" do
        deploy = Deploy.new(@default_attrs)
        stub(deploy).completion_probability { 0.50 }
        stub(deploy).completion_eta { Time.now }
        stub(deploy).completion_eta_bounds { [Time.now, Time.now] }
        assert 0.50, deploy.to_hash[:completion_probability]
      end

      it "includes the completion ETA as a timestamp" do
        now = Time.now
        deploy = Deploy.new(@default_attrs)
        stub(deploy).completion_probability { 0.50 }
        stub(deploy).completion_eta { now }
        stub(deploy).completion_eta_bounds { [Time.now, Time.now] }
        assert now.to_i, deploy.to_hash[:predicted_finished_at]
      end
    end
  end
end
