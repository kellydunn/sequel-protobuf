require 'sequel/plugins/protobuf/drivers'

module Sequel
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
        def to_protobuf(options = {})
          self.class.protobuf_driver.serialize(self.class.protobuf_model, self, options)
        end
      end

      module DatasetMethods
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
