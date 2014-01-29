require 'sequel/plugins/protobuf/drivers'

# This module contains all functionality for the Sequel library.
module Sequel
  
  # This module contains all Sequel plugin definitions.
  module Plugins

    # This module defines the Protobuf plugin for the Sequel database library
    module Protobuf

      # This error message indicates that a {Sequel::Model} definition
      # that has been required by the client is missing a protobuf model definition.
      class MissingProtobufDefinitionError < StandardError

        # Creates a new instance of {Sequel::Plugins::Protobuf::MissingProtobufDefinitionError}
        def initialize
          super("Protobuf model definition was not specified.")
        end
      end

      # This constant lists all of the current compatible drivers in sequel-protobuf
      DRIVERS = {
        :ruby_protocol_buffers => Sequel::Plugins::Protobuf::Drivers::RubyProtocolBuffers
      }

      # This constant defines the default driver for sequel-protobuf
      # If clients do not specify a driver, sequel-protobuf assumes they 
      # will use this gem.
      DEFAULT_DRIVER = :ruby_protocol_buffers
      
      # Initializes the sequel-protobuf the first time it is registered for a class.
      #
      # @param model {Sequel::Model}. The {Sequel::Model} in which to register the plugin.
      # @param options {Hash}. A configuration hash that is used to help configure the application.
      def self.apply(model, options={})
        # TODO no-op
      end
      
      # Initializes the sequel-protobuf plugin for the passed in model
      # with the passed in options
      #
      # @param model {Sequel::Model}. The {Sequel::Model} in which to register the plugin
      # @param options {Hash}. A configuration hash to configure the plugin
      def self.configure(model, options = {})
        model.instance_eval {
          if !options[:model]
            raise Sequel::Plugins::Protobuf::MissingProtobufDefinitionError.new
          else
            @protobuf_model = options[:model]
          end
          
          driver = options[:driver] ? options[:driver] : DEFAULT_DRIVER
          @protobuf_driver = DRIVERS[driver]
        }
      end
      
      
      module ClassMethods
        attr_reader :protobuf_driver, :protobuf_model

        # Creates and returns a new instance of the current class
        # from the passed in protobuf message
        #
        # @param protobuf {String}. The protobuf message to parse.
        # @param options {Hash}. An options hash that will configure the parsing.
        def from_protobuf(protobuf, options = {})
          pb_model = @protobuf_driver.parse(@protobuf_model, protobuf, options)

          # Coerce data from protobuf array to a new model
          model = self.send(:new)
          model.columns.each do |v|
            if pb_model.respond_to?("#{v}=".to_sym)
              model.send("#{v}=", pb_model.send(v.to_sym))
            end
          end
          
          return model
        end
      end

      module InstanceMethods
        # Renders the current instance of the model to a protocol buffer message
        # as it is defined in the configured protocol buffer model definition.
        #
        # @param options {Hash}. An options hash that is used to configure how 
        #                        the rendering is performed.
        # @return {String}. A protocol buffer representation of the current {Sequel::Model} instance.
        def to_protobuf(options = {})
          self.class.protobuf_driver.serialize(self.class.protobuf_model, self.values, options)
        end

        # Renders the current instance of the model to an instance of {::ProtocolBuffers::Message}.
        # 
        # @param options {Hash}.  An options hash that is used to configure how
        #                         The rendering is performed.
        # @return {::ProtocolBuffers::Message}.  A representation of the model as a {::ProtocolBuffers::Message}.
        def as_protobuf(options = {})
          attributes = self.values.inject({}) do |acc, (k, v)|
            if self.class.protobuf_model.respond_to?("#{k}=".to_sym)
              acc[k] = v
            end
            
            acc
          end
          
          return self.class.protobuf_model.new(attributes)
        end
      end

      module DatasetMethods
        # Renders the current dataset of the model into a collection of 
        # protocol buffer messages as they are defined in the configured
        # protocol buffer model definition.
        #
        # @param options {Hash}.  An options hash that is used to configure how
        #                         the rendering is preformed.
        # @return {Array}.  An array of protocol buffer messages.  Each element
        #                   In the array is a serialized version of the corresponding
        #                   object in the original dataset.
        def to_protobuf(options = {})

          res = self.all.inject([]) do |acc, obj|
            acc << obj.to_protobuf(options)
            acc
          end
          
          return res
          
        end
      end
    end
  end
end
