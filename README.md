```
                                     ___                                 __           __                 ___  
                                    /\_ \                               /\ \__       /\ \              /'___\ 
  ____     __     __   __  __     __\//\ \            _____   _ __   ___\ \ ,_\   ___\ \ \____  __  __/\ \__/ 
 /',__\  /'__`\ /'__`\/\ \/\ \  /'__`\\ \ \   _______/\ '__`\/\`'__\/ __`\ \ \/  / __`\ \ '__`\/\ \/\ \ \ ,__\
/\__, `\/\  __//\ \L\ \ \ \_\ \/\  __/ \_\ \_/\______\ \ \L\ \ \ \//\ \L\ \ \ \_/\ \L\ \ \ \L\ \ \ \_\ \ \ \_/
\/\____/\ \____\ \___, \ \____/\ \____\/\____\/______/\ \ ,__/\ \_\\ \____/\ \__\ \____/\ \_,__/\ \____/\ \_\ 
 \/___/  \/____/\/___/\ \/___/  \/____/\/____/         \ \ \/  \/_/ \/___/  \/__/\/___/  \/___/  \/___/  \/_/ 
                     \ \_\                              \ \_\                                                 
                      \/_/                               \/_/                                                 

```
[![Build Status](https://drone.io/github.com/kellydunn/sequel-protobuf/status.png)](https://drone.io/github.com/kellydunn/sequel-protobuf/latest)

##what 

A plugin library for the `sequel` gem that enables `Sequel::Model` classes to be serialized into protocol buffers.

##usage

Require the gem through `bundler`:

```
gem 'sequel-protobuf', :git => "git@github.com/kellydunn/sequel-protobuf"
```

Then, in your model definitions file, require `sequel`, `sequel-protobuf`, a protocol buffer utility library of your choice, and a `.pb.rb` definition of your protocol buffer model.  After that, just specify that you want your `Sequel::Model` class to use the `protobuf` plugin with a specific protobuf model definition, like so:

```
require 'sequel'
require 'sequel/plugins/protobuf'
require 'ruby-protocol-buffers'
require 'your/protocol/buffer/definition'

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

##considerations

  - This library currently only supports `ruby-protocol-buffers` as a serialization driver.  If there is interest, other gems might be considered for integration!  If you are interested in adding additional driver support, feel free to open a Pull Request!

##roadmap

  - Nested Dataset serialization