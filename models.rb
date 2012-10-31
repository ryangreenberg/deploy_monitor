module Models
  RESULTS = {
    :complete => 0,
    :failed => 1,
    :abandoned => 2
  }
end

require 'models/resultable'

require 'models/system'
require 'models/step'
require 'models/deploy'
require 'models/progress'

require 'models/system_statistics'