# frozen_string_literal: true

module Cnfs
  class Errors
    attr_reader :messages, :details

    def initialize
      @messages = {}
      @details = {}
    end

    def add(attribute, message = :invalid, options = {})
      @messages[attribute] = message
      @details[attribute] = options
    end

    def size; @messages.size end
  end
end
