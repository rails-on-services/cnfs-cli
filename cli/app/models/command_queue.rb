# frozen_string_literal: true

class CommandQueue
  include ActiveModel::AttributeAssignment
  include TtyHelper
  attr_reader :queue, :results
  attr_accessor :halt_on_failure, :raise_on_failure

  def initialize(**options)
    @queue = []
    @results = []
    assign_attributes(options)
  end

  # TODO: Raise an error if the command is not properly formatted
  def add(command)
    raise ArgumentError, 'Incorrect command format' unless all_good(command)

    queue.append(command)
  end

  def all_good(command)
    return unless command.instance_of?(Array)

    command.first.instance_of?(Hash) and command.second.instance_of?(String) and command.third.instance_of?(Hash)
  end

  def execute_all
    # rubocop:disable Style/WhileUntilModifier
    while queue.any?
      break if !execute && halt_on_failure
    end
    # rubocop:enable Style/WhileUntilModifier
  end

  def execute
    current_command = queue.shift
    result = command.run!(*current_command)
    results.append(result)
    if result.failure?
      raise Cnfs::Error, result.err if raise_on_failure
      return false if halt_on_failure
    end
    true
  end

  def failure?
    failures.any?
  end

  def success?
    failures.empty?
  end

  def failure_messages
    failures.map(&:err)
  end

  def failures
    results.select(&:failure?)
  end

  def successes
    results.select(&:success?)
  end

  def runtime
    results.map(&:runtime).reduce(:+)
  end
end
