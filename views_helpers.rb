require 'erubis'

module ViewsHelpers
  include ::Erubis::XmlHelper

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

  def format_metadata_value(value)
    escaped_value = h(value)
    if value =~ /^https?:\/\//
      "<a href='#{escaped_value}'>#{escaped_value}</a>"
    elsif value.include?("\n")
      "<pre class='pre-scrollable'>#{escaped_value}</pre>"
    else
      escaped_value
    end
  end
end