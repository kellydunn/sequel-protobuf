require 'sequel/plugins/protobuf/drivers'

module Sequel
  module Plugins
    module Protobuf
      class MissingProtobufDefinitionError < StandardError
        def initialize
          super("Protobuf model definition was not specified.")
        end
      end

      # TODO Find a cleaner way of registering drivers, but for now
      #      We will support `ruby_protocol_buffers`
      DRIVERS = {
        :ruby_protocol_buffers => Sequel::Plugins::Protobuf::Drivers::RubyProtocolBuffers
      }

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

          if options[:array]
            collection = options.delete(:array)

            res = collection.inject([]) do |acc, obj|
              acc << obj.to_protobuf(options)
              acc
            end

            return res

          elsif options[:root]
            obj = options.delete(:root)
            return obj.to_protobuf(options)

          end
        end
      end

    end
  end
end
