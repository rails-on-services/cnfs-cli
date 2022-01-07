# frozen_string_literal: true

require_relative 'lib/cnfs/aws/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnfs-aws'
  spec.version       = Cnfs::Aws::VERSION
  spec.authors       = ['Robert Roach']
  spec.email         = ['rjayroach@gmail.com']

  spec.summary       = 'CNFS CLI plugin for Amazon Web Services'
  spec.description   = 'CNFS CLI plugin to create CNFS compatible blueprints for AWS'
  spec.homepage      = 'https://cnfs.io'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/rails-on-services/cnfs-cli'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'cnfs-core', '~> 0.1.0'
  spec.add_dependency 'aws-sdk-acm', '~> 1.38'
  spec.add_dependency 'aws-sdk-ec2', '~> 1.211'
  spec.add_dependency 'aws-sdk-eks', '~> 1.46'
  spec.add_dependency 'aws-sdk-rds', '~> 1.107'
  spec.add_dependency 'aws-sdk-redshift', '~> 1.51'
  spec.add_dependency 'aws-sdk-route53', '~> 1.44'
  spec.add_dependency 'aws-sdk-s3', '~> 1.86'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
