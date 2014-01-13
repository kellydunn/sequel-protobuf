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

end
