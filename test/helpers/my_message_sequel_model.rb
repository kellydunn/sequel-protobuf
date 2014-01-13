require 'sequel'
require 'sequel/plugins/protobuf'

class MyMessageSequelModel < Sequel::Model
  plugin :protobuf, :model => ::Test::MyMessage
end
