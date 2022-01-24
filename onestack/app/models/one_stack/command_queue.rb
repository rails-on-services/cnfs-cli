# frozen_string_literal: true

class OneStack::CommandQueue
  include ActiveModel::AttributeAssignment
  attr_reader :queue, :results, :on_failure

  delegate :each, :map, :shfit, :unshift, :first, :last, :pop, :size, to: :queue

  def initialize(**options)
    assign_attributes(options)
    @queue = []
    @results = []
    # @on_failure ||= :raise
    @on_failure ||= ActiveSupport::StringInquirer.new('raise')
  end

  def run!
    run(cmd: :run!)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def run(cmd: :run)
    queue.each do |command|
      command.send(cmd)
      # binding.pry
      next unless command.exit_error || command.result.failure?

      msg = command.exit_error&.to_s || command.result.err
      binding.pry
      raise Hendrix::Error, msg if on_failure.raise?

      return false if on_failure.halt?
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def append(*commands)
    commands.each do |command|
      raise ArgumentError, 'Incorrect command format' unless command.instance_of?(Command)

      queue.append(command)
    end
  end

  def on_failure=(value)
    binding.pry
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
