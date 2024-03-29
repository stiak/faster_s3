# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faster_s3/version'

Gem::Specification.new do |spec|
  spec.name          = "faster_s3"
  spec.version       = FasterS3::VERSION
  spec.authors       = ["Pat Leamon"]
  spec.email         = ["patrick@redbubble.com"]
  spec.description   = %q{Download files from s3 in parallel}
  spec.summary       = %q{Faster s3 downloads}
  spec.homepage      = "https://github.com/stiak/faster_s3"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_dependency "aws-sdk"
  spec.add_dependency "parallel"
end
