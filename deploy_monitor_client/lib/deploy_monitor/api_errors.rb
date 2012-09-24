module DeployMonitor
  module ApiErrors
    def parse_error(error_json)
      begin
        obj = JSON.parse(error_json)
        Error.new(obj["type"], obj["reason"])
      rescue JSON::ParseError => e
        nil
      end
    end
  end
end