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

  # Returns a collection where all elements are at least the provided minimum
  # value without changing the sum of the elements. This is useful if you want
  # to exaggerate some elements of a progress bar without changing the
  # total width
  def with_minimum_value(arr, min_val)
    initial_sum = arr.inject(:+)
    if min_val * arr.count > initial_sum
      raise ArgumentError, "Cannot maintain initial sum #{initial_sum} and set all elements to a minimum value #{min_val}"
    end

    below_min, above_min = arr.partition {|ea| ea < min_val}
    total_increase = below_min.inject(0.0) {|accum, i| accum + (min_val - i)}
    total_available = above_min.map {|ea| ea - min_val }.inject(:+)

    arr_with_min_vals = arr.map do |ea|
      if ea < min_val
        min_val
      else
        proportion_of_sum_above_min_val = (ea - min_val).to_f / total_available
        ea - proportion_of_sum_above_min_val * total_increase
      end
    end

    arr_with_min_vals
  end
end