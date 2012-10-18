require 'test/test_helper'

describe DeployMonitor::Web do
  include Rack::Test::Methods

  def app
    DeployMonitor::Web
  end

  describe "GET /systems/:system_name/active_deploy" do
    it "redirects to current deploy if present" do
      deploy = stub
      stub(deploy).id { 123 }
      sys = stub
      stub(sys).active_deploy { deploy }
      stub(System).filter { [ sys ] }

      get "/systems/a_system/active_deploy"
      follow_redirect!
      assert_equal 'http://example.org/deploys/123', last_request.url
    end

    it "redirects to system page if no deploy is active" do
      sys = stub
      stub(sys).name { "my_system_name" }
      stub(sys).active_deploy { nil }
      stub(System).filter { [ sys ] }

      get "/systems/a_system/active_deploy"
      follow_redirect!
      assert_equal 'http://example.org/systems/my_system_name', last_request.url
    end

    it "returns 404 if the system cannot be found" do
      stub(System).filter { [] }
      get "/systems/nonexistent_system/active_deploy"
      assert last_response.not_found?
    end
  end
end