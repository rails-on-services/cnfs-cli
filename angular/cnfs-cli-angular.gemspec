# frozen_string_literal: true

require_relative 'lib/cnfs/cli/angular/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnfs-cli-angular'
  # spec.version       = File.read('VERSION').strip
  spec.version       = Cnfs::Cli::Angular::VERSION
  spec.authors       = ['Robert Roach']
  spec.email         = ['rjayroach@gmail.com']

  spec.summary       = 'CNFS CLI plugin for the Angular Framework'
  spec.description   = 'CNFS CLI plugin to create Angular repositories and services in CNFS project'
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

  # spec.add_dependency 'cnfs-cli', '~> 0.1.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
