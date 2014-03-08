require 'sequel'
require 'sequel/plugins/protobuf'

class NestedSequelModel < Sequel::Model
  plugin :protobuf, :model => ::Test::Nested
end
