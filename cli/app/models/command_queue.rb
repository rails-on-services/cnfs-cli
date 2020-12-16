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
    return unless command.class.eql? Array

    command.first.class.eql?(Hash) and command.second.class.eql?(String) and command.third.class.eql?(Hash)
  end

  def execute_all
    while queue.any? do
      break if not execute and halt_on_failure
    end
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
    failures.map { |result| result.err }
  end

  def failures
    results.select{ |result| result.failure? }
  end

  def successes
    results.select{ |result| result.success? }
  end

  def runtime
    results.map{ |result| result.runtime }.reduce(:+)
  end
end
