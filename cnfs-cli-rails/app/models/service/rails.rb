# frozen_string_literal: true

class Service::Rails < Service
  store :config, accessors: %i[is_cnfs_service profiles images], coder: YAML

  def test_commands(rspec_options = nil)
    ['bundle exec rubocop', "rails #{prefix}db:test:prepare", "#{exec_dir}bin/spring rspec #{rspec_options}"]
  end

  def console_command; 'rails console' end

  def database_seed_commands
    ["rails #{prefix}ros:db:reset:seed"]
  end

  def prefix; is_cnfs_service ? 'app:' : '' end

  def exec_dir; is_cnfs_service ? 'spec/dummy/' : '' end
  # def image_prefix; config.dig(:image, :build_args, :rails_env) end

  def build_args(target)
    @build_args ||= images[target.deployment.environment['rails_env']].try(:[], :build_args)
  end

  def context_path(relative_path)
    (!Cnfs.services_project? and is_cnfs_service) ? relative_path.join('ros') : relative_path
  end

  def command(profile)
    case profile
    when 'server'
      %w[bundle exec rails server -b 0.0.0.0 -P /tmp/server.pid]
    when 'worker'
      return %w[bundle exec sidekiq -C config/sidekiq.yml] unless is_cnfs_service

      %w[bundle exec sidekiq -r spec/dummy -C config/sidekiq.yml]
    when 'sqs_worker'
      %w[bundle exec shoryuken -r ./app/workers/aws -C config/shoryuken.yml]
    when 'scheduler'
     %w[bundle exec rails runner ./lib/scheduler.rb]
    end
  end
end
