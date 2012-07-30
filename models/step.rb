require 'sequel/plugins/json_serializer'

class Step < Sequel::Model
  many_to_one :deploy
  many_to_one :deploy_step

  @json_serializer_opts = {:naked => true}
  self.plugin :json_serializer
end