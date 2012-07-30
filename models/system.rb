require 'sequel/plugins/json_serializer'

class System < Sequel::Model
  one_to_many :deploy_steps
  one_to_many :deploys

  @json_serializer_opts = {:naked => true}
  self.plugin :json_serializer
end