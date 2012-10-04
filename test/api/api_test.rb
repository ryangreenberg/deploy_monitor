require 'test/test_helper'

describe DeployMonitor::API do
  include Rack::Test::Methods

  def app
    DeployMonitor::API
  end

  describe "GET /deploys/:id" do
    it "returns 404 when provided deploy does not exist" do
      non_existent_deploy = 123
      get "/deploys/#{non_existent_deploy}"
      assert last_response.not_found?
    end
  end

  describe "POST /deploys/:id/complete" do
    it "returns 400 when result is unknown" do
      deploy = stub
      stub(deploy).active { true }
      stub(Deploy).[] { deploy }
      post "/deploys/123/complete", {"result" => "borked"}
      assert last_response.bad_request?
    end
  end

  describe "GET /systems/:system_name" do
    it "returns 404 when provided system does not exist" do
      non_existent_system = "frontend"
      get "/systems/#{non_existent_system}"
      assert last_response.not_found?
    end
  end
end