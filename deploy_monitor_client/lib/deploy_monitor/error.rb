module DeployMonitor
  class Error
    class DeployInProgress < RuntimeError; end
    class DeployNotActive < RuntimeError; end
    class DuplicateDeployStep < RuntimeError; end
    class DuplicateEntity < RuntimeError; end
    class RequiredParamMissing < RuntimeError; end
    class SystemHasNoSteps < RuntimeError; end
    class UnknownResult < RuntimeError; end
    class UnknownStep < RuntimeError; end

    ERROR_CLASS = {
      :deploy_in_progress => DeployInProgress,
      :deploy_not_active => DeployNotActive,
      :duplicate_deploy_step => DuplicateDeployStep,
      :duplicate_entity => DuplicateEntity,
      :required_param_missing => RequiredParamMissing,
      :system_has_no_steps => SystemHasNoSteps,
      :unknown_result => UnknownResult,
      :unknown_step => UnknownStep,
    }

    attr_reader :type, :reason

    def initialize(type, reason)
      @type = type.downcase.to_sym
      @reason = reason
    end

    def to_exception
      (ERROR_CLASS[@type] || RuntimeError).new(@reason)
    end
  end
end
