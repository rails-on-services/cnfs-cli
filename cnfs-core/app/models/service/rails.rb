# frozen_string_literal: true

class Service::Rails < Service
  store :config, accessors: %i[ros profiles images], coder: YAML

  def test_commands(rspec_options = nil)
    ['bundle exec rubocop', "rails #{prefix}db:test:prepare", "#{exec_dir}bin/spring rspec #{rspec_options}"]
  end

  def database_seed_commands
    ["rails #{prefix}ros:db:reset:seed"]
  end

  def prefix; ros ? 'app:' : '' end

  def exec_dir; ros ? 'spec/dummy/' : '' end
end
