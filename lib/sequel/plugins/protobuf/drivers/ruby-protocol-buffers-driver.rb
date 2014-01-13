module Sequel
  module Plugins
    module Protobuf
      module Drivers
        module RubyProtocolBuffers
             
          def self.parse(protobuf_model, protobuf, options = {})
            return protobuf_model.send(:parse, protobuf)
          end
          
          def self.serialize(protobuf_model, attributes, options = {})
            return protobuf_model.send(:new, attributes).to_s
          end

        end
      end
    end
  end
end
