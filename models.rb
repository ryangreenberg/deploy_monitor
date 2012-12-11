module Models
  RESULTS = {
    :complete => 0,
    :failed => 1,
    :abandoned => 2
  }

  DEFAULT_DEPLOY_STATS_WINDOW = 100
end

require 'models/resultable'

# DB
require 'models/system'
require 'models/system_lock'
require 'models/step'
require 'models/deploy'
require 'models/progress'

# Pure Ruby
require 'models/dataset_pagination'
require 'models/deploy_prediction'
require 'models/statistics_helpers'
require 'models/step_display'
require 'models/step_statistics'
require 'models/lazy_step_statistics'
require 'models/system_statistics'
