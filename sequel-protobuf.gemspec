require File.expand_path("../lib/sequel-protobuf/version.rb", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["kellydunn"]
  gem.email         = ["defaultstring+sequel-protobuf@gmail.com"]
  gem.description   = %q{Sequel plugin for protocol buffer serialization}
  gem.summary       = %q{Sequel plugin for protocol buffer serialization}
  gem.homepage      = 'http://github.com/kellydunn/sequel-protobuf'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'sequel-protobuf'
  gem.require_paths = ['lib']
  gem.version       = SequelProtobuf::VERISON
end