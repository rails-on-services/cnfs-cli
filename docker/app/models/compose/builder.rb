# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Compose::Builder < Builder
  # attr_accessor :queue, :services, :context

  # delegate :options, :labels, to: :context

  # TODO: Is this necessary?
  def supported_service_types
    ['Service::Rails', nil]
  end

  # What to do about this one?
  # def method_missing(method, *args)
  #   Cnfs.logger.warn 'command not supported in compose runtime'
  #   raise Cnfs::Error, 'command not supported in compose runtime'
  # end

  # def supported_commands
  #   %w[build test push pull publish
  #      destroy deploy redeploy
  #      start restart stop terminate
  #      ps status
  #      attach command console copy credentials exec logs shell]
  #   # list show generate
  # end

  # Image Operations
  def build(services)
    rv compose("build --parallel #{services.pluck(:name).join(' ')}")
  end

  def pull(services)
    rv compose("pull #{services.pluck(:name).join(' ')}")
  end

  def push(services)
    rv compose("push #{services.pluck(:name).join(' ')}")
  end
end
