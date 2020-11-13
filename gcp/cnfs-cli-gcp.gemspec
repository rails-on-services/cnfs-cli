require_relative 'lib/cnfs/cli/gcp/version'

Gem::Specification.new do |spec|
  spec.name          = "cnfs-cli-gcp"
  spec.version       = Cnfs::Cli::Gcp::VERSION
  spec.authors       = ["Robert Roach"]
  spec.email         = ["rjayroach@gmail.com"]

  spec.summary       = 'Create CNFS compatible blueprints for GCP'
  spec.description   = 'Adds the functionality to create GCP blueprints and access services'
  spec.homepage      = 'https://cnfs.io'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/rails-on-services/cnfs-cli'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
