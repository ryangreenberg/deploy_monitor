require 'sequel/plugins/json_serializer'

class Step < Sequel::Model
  many_to_one :system

  @json_serializer_opts = {:naked => true}
  self.plugin :json_serializer
end