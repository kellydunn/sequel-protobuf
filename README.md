#sequel-protobuf
[![Build Status](https://drone.io/github.com/kellydunn/sequel-protobuf/status.png)](https://drone.io/github.com/kellydunn/sequel-protobuf/latest)

##what 

A plugin for the `sequel` database library that enables `Sequel::Model` classes to be serialized into protocol buffers.

##documentation

Documentation can be found [here](http://rubydoc.info/github/kellydunn/sequel-protobuf/master/frames).

##installation

There is an intent to have this gem available through rubygems eventually, but for now, it's easiest to require the gem through `bundler` by specifying it in your `Gemfile`:

**Gemfile**
```
gem 'sequel-protobuf', :git => "git@github.com/kellydunn/sequel-protobuf"
```

##usage

In your `Sequel::Model` definition, require `sequel`, `sequel-protobuf`, a protocol buffer utility library of your choice (like `ruby-protocol-buffers`), and the corresponding protocol buffer model definition (the `.pb.rb` file that `ruby-protoc` generates).  Next, specify that you want your `Sequel::Model` class to use the `protobuf` plugin along with the class name of the protobuf model definition, like so:

```
require 'sequel'
require 'sequel/plugins/protobuf'
require 'protocol_buffers'
require 'your/protocol/buffer/definitions/my_model_definition'

class MyModel < Sequel::Model
  plugin :protobuf, :model => MyModelDefinition
end
```

Now you can create a new instance of your record, and call `to_protobuf` or `from_protobuf` on it!

Simple `Sequel::Dataset` operations will also work as well!

```
5.times do 
  MyModel.create()
end

result = MyModel.all.to_protobuf
# result is an array of protocol buffer representations of each instance of {MyModel}!
```

##configuration

As of `0.2.0`, `sequel-protobuf` provides the ability to render nested protocol buffer models, re-format data-types on demand, and override default protocol buffer definitions while rendering.  To do this, you may supply an options hash to the `to_protobuf` and `as_protobuf` methods with any of the following keys:

  - `:include`: specifies nested protocol buffer models to render
  - `:as`: specifies a different protocol buffer model definition in which to render the current object as
  - `:coerce`: specifies how to re-format a specific data column of the current `Sequel::Model` such that it can fit your protocol buffer definition.

###Example
```
require 'sequel'
require 'sequel/plugins/protobuf'
require 'protocol_buffers'
require 'your/protocol/buffer/definitions/my_model_definition'

class MyModel < Sequel::Model
  plugin :protobuf, :model => MyModelDefinition
  one_to_many :nested

  def app_specific_as_protobuf
    config = {
      :as => DifferentModelDefinition,
      :include => {
        :nested => {}
      }
      :coerce => {
        # We coerce the creatd_at time since Protocol Buffers
        # do not support Time types by default.
        # The reccomended approach is to set the unix timestamp value
        # as a int64 type.
        :created_at => Proc.new { |created_at|
          created_at.utc.to_i
        }
      }
    }

    return self.as_protobuf(config)
  end
end
```

##considerations

  - This library currently only supports `ruby-protocol-buffers` as a serialization driver.  If you are interested in adding additional driver support, feel free to open a Pull Request!

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/kellydunn/sequel-protobuf/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

