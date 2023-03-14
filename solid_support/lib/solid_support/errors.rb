# frozen_string_literal: true

module Cnfs
  class Errors
    attr_reader :messages

    def initialize
      @messages = []
    end

    def add(attribute, message = :invalid, options = {})
      @messages.append(command: attribute, message: message, options: options)
    end

    def size
      @messages.size
    end

    def full_messages
      messages.map { |error| "#{error[:command]}: #{error[:message]}" }.join("\n")
    end
  end
end
