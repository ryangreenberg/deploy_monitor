module Errors
  TYPES = {
    :required_param_missing => "Missing required param '%s'",
    :not_found => "%s could not be found",
    :duplicate_entity => "%s already exists with id %s",
    :deploy_in_progress => "Cannot create new deploy for '%s' because deploy id %s is in progress",
    :system_has_no_steps => "Cannot create new deploy for '%s' because there are no steps",
    :unknown_result => "Cannot complete deploy using unknown result '%s'",
    :unknown_step => "Cannot add unknown step '%s' to deploy",
    :deploy_not_active => "Deploy is not active",
    :duplicate_deploy_step => "Deploy is already at step '%s'"
  }

  def self.format(type, *strfmt_args)
    error_string = TYPES[type]
    raise ArgumentError, "Unknown error type '#{type}'" unless error_string
    {
      :type => type.to_s.upcase,
      :reason => error_string % strfmt_args
    }.to_json
  end
end