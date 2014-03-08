require 'sequel'
require 'sequel/plugins/protobuf'
require 'test/helpers/nested_sequel_model'

class MyMessageSequelModel < Sequel::Model
  plugin :protobuf, :model => ::Test::MyMessage
  one_to_many :nested, :class => NestedSequelModel
end
