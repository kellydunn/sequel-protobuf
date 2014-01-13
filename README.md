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

```
gem install sequel-protobuf
```

```
require 'sequel'
require 'sequel/plugins/protobuf'
require 'ruby-protocol-buffers'
require 'your/protocol/buffer/definition'

class MyModel < Sequel::Model
  plugin :protobuf, :model => MyModelDefinition
end
```

Then later, you can create a new instance of your record, and call `to_protobuf` or `from_protobuf` on it.

That's it!