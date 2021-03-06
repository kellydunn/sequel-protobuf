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
      
      # When mixed in, this module provides the ability for objects 
      # to be serialized from protocol buffer strings
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

      # When mixed in, this module provides various instance-level methods that
      # allow sequel models to be rendered into protocol buffers
      # or rendered into a driver-specific model 
      module InstanceMethods

        # Renders the current instance of the model to a protocol buffer message
        # as it is defined in the configured protocol buffer model definition.
        #
        # @param options {Hash}. An options hash that is used to configure how 
        #                        the rendering is performed.
        # @return {String}. A protocol buffer representation of the current {Sequel::Model} instance.
        def to_protobuf(options = {})
          return self.render(self, options).to_s
        end

        # Renders the current instance of the model to an instance of {::ProtocolBuffers::Message}.
        # 
        # @param options {Hash}.  An options hash that is used to configure how
        #                         The rendering is performed.
        # @return {Object}.  A representation of the model as an instance of the protocol_buffer model class
        #                    configured at the instance level.
        def as_protobuf(options = {})
          return self.render(self, options)
        end

        # Renders the passed in key ans the corresponding protocol buffer model.
        # The passed in options specifies how to do this with the following rules:
        #   - `:include`  This key specifies that the current protocol buffer model has a nested
        #                 Protocol buffer model to be rendered inside of it.
        #   - `:coerce`   This key specifies that the current model can override a specific data
        #                 value of a particular database column.  This is useful fo re-formatting
        #                 data from your db schema so that they adhere to your protocol 
        #                 buffer definitions.
        #   - `:as`       This key specifies a different protocol buffer model to render the
        #                 current object.
        #
        # @param current {Object}.  The current seciton of the schema to render.
        # @param options {Hash}.  An options hash to configure how to render the current object.
        def render(current, options={})

          # If the current element in the schema is an array, 
          # then we need to render them in sequence and return the result.
          if current.is_a?(Array)
            collection = current.inject([]) do |acc, element|
              acc << render(element, options) 
              acc
            end

            return collection

          # Otherwise, if the record isn't nil, 
          # we get the current values of the object and process them accordingly.
          elsif !current.nil?
            values = current.values.dup
            
            # If the options do not specifiy a protobuf model, assume the one configured earlier
            if options.has_key?(:as) 
              model = options[:as]
            else
              model = current.class.protobuf_model
            end
            
            options.each do |k, v|
              
              # If the current key is "include", then recursively render the model specified
              if k == :include
                v.each do |model, opts|
                  values.merge!({model => render(current.send(model.to_sym), opts)})
                end

              # If the current key is "coerce", then call the corresponding proc
              # for the desired attribute
              elsif k == :coerce
                v.each do |value, proc|
                  values[value] = proc.call(values[value])
                end
              end
            end
            
            # Finally, return the result of creating a new protobuf model
            return current.class.protobuf_driver.create(model, values)
          end
        end

      end

      # When mixed in, this module provides the ability for Sequel datasets to 
      # call `to_protobuf`, which will return an array of serialized protobuf strings.
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
