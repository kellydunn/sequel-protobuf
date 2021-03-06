$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))

# Simplecov needs to be required before test/unit
# in order for the test suite runner to be tracked during code-coverage generation
require 'simplecov'
SimpleCov.start 

require 'minitest'
require 'minitest/autorun'
require 'mocha/setup'
require 'sequel'

Sequel.mock(:fetch => [{ :id => 1, 
                         :myField => "test", 
                         :extraField => "extra",
                         :nestedField => "test-nested"}], 

            :columns => [:id, 
                         :myField, 
                         :extraField,
                         :my_message_id,
                         :nestedField])

# Require all protobuf definitions
Dir["**/*.pb.rb"].each do |f|
  require File.absolute_path(f)
end

# Require unit tests
Dir["**/*_test.rb"].each do |f|
  require File.absolute_path(f)
end
