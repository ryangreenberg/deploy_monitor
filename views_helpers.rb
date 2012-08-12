module ViewsHelpers
  def display_label(deploy)
    if deploy.active
      'label-info'
    else
      if deploy.complete?
        'label-success'
      elsif deploy.failed?
        'label-important'
      end
    end
  end
end