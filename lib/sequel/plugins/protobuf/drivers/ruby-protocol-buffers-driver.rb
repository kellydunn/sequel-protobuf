module Sequel
  module Plugins
    module Protobuf
      
      # This module contains all the driver definitions for the sequel-protobuf gem.
      module Drivers
        
        # This driver definition provides a standard interface
        # for protocol buffer serialization with the `ruby-protocol-buffers` gem.
        module RubyProtocolBuffers
             
          # Parses the passed in protobuf message into 
          # an instance of the corresponding protocol buffer model definition
          #
          # @param protobuf_model {Object}.  The class of the protocol buffer definition
          # @param protobuf {String}.  The protocol buffer message to be parsed
          # @param options {Hash}.  An options hash to help configure the parsing functionality.
          def self.parse(protobuf_model, protobuf, options = {})
            return protobuf_model.send(:parse, protobuf)
          end
          
          # Serializes the passed in attributes hash into an instance of the passed in
          # protocol buffer model definition.
          #
          # @param protobuf_model {Object}. The class of the protocol buffer definition
          # @param attributes {Hash}.  The attributes in which to be serialized into a protocol buffer message
          # @param options {Hash}.  An options hash to help configure the serialization funcitonality.
          def self.serialize(protobuf_model, attributes, options = {})
            return self.create(protobuf_model, attributes, options).to_s
          end

          def self.create(protobuf_model, attributes, options = {})
            fields = protobuf_model.fields.inject([]) do |acc, (k, v)| 
              acc << v.name
              acc
            end
            
            attributes.reject! do |item| 
              !fields.include?(item)
            end
            
            return protobuf_model.send(:new, attributes)

          end

        end

      end
    end
  end
end
