# frozen_string_literal: true

require_relative 'lib/solid_support/version'

Gem::Specification.new do |spec|
  spec.name          = 'solid_support'
  spec.version       = SolidSupport::VERSION
  spec.authors       = ['Robert Roach']
  spec.email         = ['rjayroach@gmail.com']

  spec.summary       = 'Support classes for Hendrix'
  spec.description   = 'Support classes and Ruby core extensions for the Hendrix Framework'
  spec.homepage      = 'https://hendrix.cnfs.io'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/cnfs.io/solid-support'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 6.1'
  spec.add_dependency 'tty-command', '~> 0.10'
  spec.add_dependency 'tty-spinner', '~> 0.9'
  spec.add_dependency 'tty-file', '~> 0.10'
  spec.add_dependency 'tty-tree', '~> 0.4'

  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.22'
end
