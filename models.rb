module Models
  RESULTS = {
    :complete => 0,
    :failed => 1,
    :abandoned => 2
  }
end

require 'models/resultable'

# DB
require 'models/system'
require 'models/step'
require 'models/deploy'
require 'models/progress'

# Pure Ruby
require 'models/deploy_prediction'
require 'models/progress_statistics'
require 'models/system_statistics'
