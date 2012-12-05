require 'test/test_helper'
require 'models'

describe DatasetPagination do
  describe "#paged_dataset" do
    before(:each) do
      @dataset = Deploy.dataset # Could be any arbitrary dataset
      @default_limit = 10
      @max_limit = 100
      @dataset_pagination = DatasetPagination.new(@dataset, @default_limit, @max_limit)
    end

    it "uses the default limit when a user limit is not provided" do
      ds = @dataset_pagination.paged_dataset
      assert_includes ds.sql, "LIMIT #{@default_limit}"
    end

    it "uses the user limit when provided" do
      user_limit = 50
      ds = @dataset_pagination.paged_dataset(user_limit)
      assert_includes ds.sql, "LIMIT #{user_limit}"
    end

    it "uses the default limit if the user limit is above the max allowed" do
      user_limit = @max_limit + 1
      ds = @dataset_pagination.paged_dataset(user_limit)
      assert_includes ds.sql, "LIMIT #{@max_limit}"
    end

    it "uses the user offset when provided" do
      user_offset = 25
      ds = @dataset_pagination.paged_dataset(nil, user_offset)
      assert_includes ds.sql, "OFFSET #{user_offset}"
    end
  end
end
