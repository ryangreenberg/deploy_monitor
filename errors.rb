module Errors
  TYPES = {
    :deploy_in_progress => "Cannot start deploy for '%s' because deploy id %s is in progress",
    :deploy_not_active => "Deploy is not active",
    :duplicate_deploy_step => "Deploy is already at step '%s'",
    :duplicate_entity => "%s already exists with id %s",
    :invalid_number => "Step number '%s' is not valid",
    :not_found => "%s could not be found",
    :required_param_missing => "Missing required param '%s'",
    :system_has_no_steps => "Cannot start deploy for '%s' because there are no steps",
    :unknown_result => "Cannot complete deploy using unknown result '%s'",
    :unknown_step => "Cannot advance deploy to unknown step '%s'",
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