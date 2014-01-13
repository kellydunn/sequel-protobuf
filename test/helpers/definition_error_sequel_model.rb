require 'sequel'
require 'sequel/plugins/protobuf'

class DefinitionErrorSequelModel < Sequel::Model
  plugin :protobuf
end
