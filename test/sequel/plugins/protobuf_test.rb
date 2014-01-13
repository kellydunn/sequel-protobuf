$LOAD_PATH.unshift(".")

require 'sequel/plugins/protobuf'

class ProtobufTest < Minitest::Test
  def test_mixin
    require 'test/helpers/my_message_sequel_model'

    m = MyMessageSequelModel.create
    assert m.respond_to?(:to_protobuf), "A new sequel model should respond to `to_protobuf`"
    assert m.class.respond_to?(:from_protobuf), "The class of a new sequel model should respond to `from_protobuf`"
  end

  def test_mixin_error
    begin
      require 'test/helpers/definition_error_sequel_model'
    rescue Exception => e
      assert_equal e.class, Sequel::Plugins::Protobuf::MissingProtobufDefinitionError
      assert_equal e.to_s, "Protobuf model definition was not specified."
    end
  end

  def test_to_protobuf
    require 'test/helpers/my_message_sequel_model'

    m = MyMessageSequelModel.create({:myField => "test"})
    res = m.to_protobuf

    assert_equal res, "\b\x01\x12\x04test"
  end

  def test_from_protobuf
    require 'test/helpers/my_message_sequel_model'

    m = MyMessageSequelModel.from_protobuf("\b\x01\x12\x04test")
    
    assert_equal m.id, 1
    assert_equal m.myField, "test"
    assert_equal m.class, MyMessageSequelModel
  end

  def test_dataset_to_protobuf
    require 'test/helpers/my_message_sequel_model'

    m = MyMessageSequelModel.create({:myField => "test"})
    collection = MyMessageSequelModel.where(:myField => "test")

    res = collection.to_protobuf

    assert_equal(res.length, 1)
    assert_equal(res[0], "\b\x01\x12\x04test")    
  end
end
