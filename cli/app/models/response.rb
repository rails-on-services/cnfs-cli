# frozen_string_literal: true

class Response
  attr_accessor :commands

  def initialize
    @commands = []
  end

  def add(exec:, env: {}, pty: false)
    commands << OpenStruct.new(exec: exec, env: env, pty: pty)
  end
end
