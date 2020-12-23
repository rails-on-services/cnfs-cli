# frozen_string_literal: true

class ApplicationView < TTY::Prompt
  attr_accessor :model

  def initialize(model:, **options)
    @model = model
    super(default_options.merge(options))
  end

  def per_page(array, buffer = 3)
    [TTY::Screen.rows, array.size].max - buffer
  end

  def default_options
    { help_color: :cyan }
  end
end
