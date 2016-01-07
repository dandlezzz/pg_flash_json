# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_flash_json/version'

Gem::Specification.new do |spec|
  spec.name          = "pg_flash_json"
  spec.version       = PgFlashJson::VERSION
  spec.authors       = ["dandlezzz"]
  spec.email         = ["danm@workwithopal.com"]

  spec.summary       = %{Use postgres to generate json from active record relations.}
  spec.description   = %q{This gem allows you to rapidly generate large amount of json in an activerecord application. By relying on postgres' native functionality,
                          we can skip object instantiation and turn active record queries directly into json.}
  spec.homepage      = "https://github.com/dandlezzz/pg_flash_json"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["benchmarks"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "activerecord", "~> 4.2"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "benchmark-ips"
end
