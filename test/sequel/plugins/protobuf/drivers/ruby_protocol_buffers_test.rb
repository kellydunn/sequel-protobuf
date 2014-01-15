require 'sequel/plugins/protobuf/drivers/ruby-protocol-buffers-driver'

class RubyProtocolBuffersDriverTest < Minitest::Test
  # Ensures that a protocol buffer defition can be serailized as expected
  # with ruby-protocol-buffers as the driver
  def test_serialize
    d = Sequel::Plugins::Protobuf::DRIVERS[:ruby_protocol_buffers]
    res = d.serialize(::Test::MyMessage, {:id => 1, :myField => "test"})
    assert_equal("\b\x01\x12\x04test", res)
  end

  # Ensures that result of serialize can read with the driver's call to `parse`
  # Also ensures that a successful parse will result in a new protobuf model
  # with the expected fields
  def test_parse
    d = Sequel::Plugins::Protobuf::DRIVERS[:ruby_protocol_buffers]
    msg = ::Test::MyMessage.new({:id => 1, :myField => "test"})
    res = d.serialize(::Test::MyMessage, {:id => 1, :myField => "test"})
    res2 = d.parse(::Test::MyMessage, res)
    assert_equal(msg, res2)
    assert_equal(res2.myField, "test")
  end

  # Ensures that passing an attributes hash that is mismatched with the 
  # Protobuf definition will be coerced into an acceptable attributes hash 
  # such that it can be serialized as defined
  def test_serialize_with_mismatched_attributes
    e = nil
    begin
      d = Sequel::Plugins::Protobuf::DRIVERS[:ruby_protocol_buffers]
      res = d.serialize(::Test::MyMessage, {:id => 1, :myField => "test", :garbage => "garbage_data"})
      assert_equal("\b\x01\x12\x04test", res)
    rescue ::Exception => e
      # No-op
    end

    assert e.nil?, "We should not encounter an error when attempting to serialize a model with mismatched attributes"
  end

  # Ensures that we do encounter an error when an insufficent attributes hash
  # Is passed to a call to serialization
  def test_serialize_with_mismatched_attributes_error
    e = nil
    begin
      d = Sequel::Plugins::Protobuf::DRIVERS[:ruby_protocol_buffers]
      res = d.serialize(::Test::MyMessage, {})
    rescue ::Exception => e
      # No-op
    end

    assert !e.nil?, "We should encounter an error when attempting to serialize a model with insufficient attributes"
    assert_equal e.class, ::ProtocolBuffers::EncodeError
  end

end
