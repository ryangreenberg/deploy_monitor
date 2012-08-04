module DeployMonitor
  class ExceptionSilencingProxy
    def initialize(obj, logger)
      @obj = obj
      @logger = logger
    end

    def method_missing(method_name, *args)
      begin
        @obj.send(method_name, *args)
      rescue Exception => e
        @logger.warn(e)
      end
    end
  end
end