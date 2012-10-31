# Classes that mixin Resultable must provide:
# 1. an active? method
# 2. a result method that returns an integer value from Models::RESULTS
module Resultable
  def complete?
    result == Models::RESULTS[:complete]
  end

  def failed?
    result == Models::RESULTS[:failed]
  end

  def status_label
    if active?
      'in progress'
    else
      Models::RESULTS.invert[result]
    end
  end
end