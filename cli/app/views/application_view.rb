# frozen_string_literal: true

class ApplicationView < TTY::Prompt
  attr_accessor :model

  def initialize(model:, **options)
    @model = model
    super(options)
  end
end
