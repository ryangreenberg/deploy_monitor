require 'test/test_helper'

describe Paths do
  describe "#for_deploy" do
    it "returns a URL with the id of the provided deploy" do
      deploy = stub
      stub(deploy).id { 123 }
      assert_equal "/deploys/123", Paths.for_deploy(deploy)
    end
  end

  describe "#for_system" do
    it "returns a URL with the name of the provided system" do
      sys = stub
      stub(sys).name { "my_system" }
      assert_equal "/systems/my_system", Paths.for_system(sys)
    end
  end
end
