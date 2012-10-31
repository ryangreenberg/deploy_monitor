require 'erubis'

module ViewsHelpers
  include ::Erubis::XmlHelper

  def result_label_css_class(obj)
    if obj.active?
      'label-info'
    else
      if obj.complete?
        'label-success'
      elsif obj.failed?
        'label-important'
      end
    end
  end

  def result_symbol(obj)
    if obj.active?
      '&hellip;' # ellipsis
    else
      if obj.complete?
        '&#10003;' # checkmark
      elsif obj.failed?
        '&#10007;' # ballot X
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