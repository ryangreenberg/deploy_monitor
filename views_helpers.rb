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

  def format_percent(value, digits=0)
    rounded_val = (value * 10**(2 + digits)).round.to_f / 10**(digits)
    digits == 0 ? rounded_val.to_i : rounded_val
  end

  def color_for_completion_rate(percentage)
    if percentage >= 0.95
      'bar-success'
    elsif percentage >= 0.85
      'bar-warning'
    else
      'bar-danger'
    end
  end

  def data_updated_at
    %|data-updated-at="#{Time.now.to_i}"|
  end
end