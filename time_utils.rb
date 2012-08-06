module TimeUtils
  def hms(total_secs)
    hours = (total_secs / 3600).floor
    mins = ((total_secs - (hours * 3600)) / 60).floor
    secs = (total_secs - (hours * 3600) - (mins * 60)).floor
    [hours, mins, secs]
  end

  def zero_pad(num, digits)
    "0" * (digits - num.to_s.size) + num.to_s
  end

  # Replaces %H with hours, %M with minutes, %S with seconds
  # Replaces (%?H) with hours if > 0
  def format_hms(format_str, total_secs)
    h, m, s = hms(total_secs)
    m, s = zero_pad(m, 2), zero_pad(s, 2)
    str = format_str.gsub('%H', h.to_s).gsub('%M', m.to_s).gsub('%S', s.to_s)
    if h > 0
      str.gsub!(/\(%\?H(.*?)\)/, "#{h}\\1")
    else
      str.gsub!(/\(%\?H(.*?)\)/, h > 0 ? "#{h}\\1" : '')
    end
    str
  end
end