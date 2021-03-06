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
          # @return {::ProtocolBuffers::Message}.  A newly created protocol buffer message
          def self.serialize(protobuf_model, attributes, options = {})
            return self.create(protobuf_model, attributes, options).to_s
          end

          # Creates and returns a new instance of the specified protobuf model 
          # initialized with the passed in attributes and configured by the passed in optoins.
          # 
          # @param protobuf_model {Object}.  The protobuf model in which to render.
          # @param attributes {Hash}.  A hash of attributes in which to create the new protobuf model
          # @param options {Hash}.  A configuration hash in which to configure the creation of the
          #                         New protocol buffer object.
          # @return {::ProtocolBuffers::Message}.  A newly created protocol buffer message.
          def self.create(protobuf_model, attributes, options = {})
            fields = protobuf_model.fields.inject([]) do |acc, (k, v)| 
              acc << v.name
              acc
            end
            
            attributes = attributes.inject({}) do |acc, (k, v)| 
              if fields.include?(k)
                acc[k] = v
              end

              acc
            end
            
            return protobuf_model.send(:new, attributes)

          end

        end

      end
    end
  end
end
