# frozen_string_literal: true

require_relative 'lib/cnfs/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnfs-cli-core'
  spec.version       = Cnfs::VERSION
  spec.authors       = ['Robert Roach']
  spec.email         = ['rjayroach@gmail.com']

  spec.summary       = 'CNFS CLI Core Services'
  spec.description   = 'CNFS CLI plugin to install service configurations into CNFS projects'
  spec.homepage      = 'https://cnfs.io'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

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

  spec.add_dependency 'activerecord', '~> 6.1'
  spec.add_dependency 'activesupport', '~> 6.1'
  spec.add_dependency 'config', '~> 2.2'
  # spec.add_dependency 'json_schemer'
  spec.add_dependency 'lockbox', '~> 0.4'
  spec.add_dependency 'pry', '~> 0.13'
  spec.add_dependency 'sqlite3', '~> 1.4'
  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'thor-hollaback', '~> 0.2'

  spec.add_dependency 'tty-command', '~> 0.10'
  spec.add_dependency 'tty-file', '~> 0.10.0'
  spec.add_dependency 'tty-logger', '~> 0.5'
  spec.add_dependency 'tty-prompt', '~> 0.22'
  spec.add_dependency 'tty-screen', '~> 0.8'
  spec.add_dependency 'tty-spinner', '~> 0.9'
  spec.add_dependency 'tty-table', '~> 0.12.0'
  spec.add_dependency 'tty-tree', '~> 0.4'
  spec.add_dependency 'tty-which', '~> 0.5'

  # spec.add_dependency "tty-box", "~> 0.4.1"
  # spec.add_dependency "tty-color", "~> 0.5"
  # spec.add_dependency "tty-config", "~> 0.3.2"
  # spec.add_dependency "tty-cursor", "~> 0.7"
  # spec.add_dependency "tty-editor", "~> 0.5"
  # spec.add_dependency "tty-font", "~> 0.4.0"
  # spec.add_dependency "tty-markdown", "~> 0.6.0"
  # spec.add_dependency "tty-pager", "~> 0.12"
  # spec.add_dependency "tty-pie", "~> 0.3.0"
  # spec.add_dependency "tty-platform", "~> 0.2"
  # spec.add_dependency "tty-progressbar", "~> 0.17"
  # spec.add_dependency "tty-which", "~> 0.4"

  spec.add_dependency 'xdg', '~> 5'
  spec.add_dependency 'zeitwerk', '~> 2.4'

  spec.add_development_dependency 'bump', '~> 0.10'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  # spec.add_development_dependency "awesome_print"
end
