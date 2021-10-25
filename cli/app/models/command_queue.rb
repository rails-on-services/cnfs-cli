# frozen_string_literal: true

class CommandQueue
  include ActiveModel::AttributeAssignment
  attr_reader :queue, :results, :on_failure

  delegate :each, :map, :shfit, :unshift, :first, :last, :pop, :size, to: :queue

  def initialize(**options)
    @queue = []
    @results = []
    self.on_failure ||= :raise_it
    assign_attributes(options)
  end

  def run!
    run(cmd: :run!)
  end

  def run(cmd: :run)
    queue.each do |command|
      command.send(cmd)
      binding.pry
      if command.exit_error || command.result.failure?
        msg = command.exit_error&.to_s || command.result.err
        raise Cnfs::Error, msg if on_failure.raise?

        return false if on_failure.halt?
      end
    end
  end

  def append(*commands)
    commands.each do |command|
      raise ArgumentError, 'Incorrect command format' unless command.instance_of?(Command)

      queue.append(command)
    end
  end

  def on_failure=(value)
    @on_failure ||= ActiveSupport::StringInquirer.new(value.to_s)
  end

#   def execute
#     current_command = queue.shift
#     result = command.run!(*current_command)
#     results.append(result)
#     true
#   end
#
#   def failure?
#     failures.any?
#   end
#
#   def success?
#     failures.empty?
#   end
#
#   def failure_messages
#     failures.map(&:err)
#   end
#
#   def failures
#     results.select(&:failure?)
#   end
#
#   def successes
#     results.select(&:success?)
#   end
#
#   def runtime
#     results.map(&:runtime).reduce(:+)
#   end
end
