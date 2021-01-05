# frozen_string_literal: true

class PostProcessor::Vagrant::View < Cnfs::TTY::Prompt
  include ViewHelper

  def create
    prompt.key(:keep_input_artifact).yes?('Keep input artifact?')
  end
end

