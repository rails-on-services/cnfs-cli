# frozen_string_literal: true

class ApplicationView < TTY::Prompt
  attr_accessor :model

  def initialize(model:, **options)
    @model = model
    super(**default_options.merge(options))
  end

  def default_options
    { help_color: :cyan }
  end

  # Set an attribute from a Prompt.select result
  # 
  # ==== Examples
  # view_select(:instance_family, model.offers_by_family, model.family)
  #
  # ==== Parameters
  # title<String>:: The title text to display to the user. If it is also an attribute of the object ti will be set
  # data<Array>:: An array of data to be presented to the user as a select list
  # current<String>:: The default value in the Arraye
  #
  def view_select(title, data, current = nil)
    result = select(title.to_s.humanize, per_page: per_page(data), filter: true, show_help: :always) do |menu|
      menu.help 'Type to filter results'
      menu.choices data
      menu.default ((data.index(current) || 0) + 1) if current
      yield menu if block_given?
    end
    attribute = "#{title}="
    send(attribute, result) if respond_to?(attribute)
    result
  end

  def per_page(array, buffer = 3)
    [TTY::Screen.rows, array.size].max - buffer
  end

  def random_string(name = nil, length: 12)
    rnd = (0...length).map { (65 + rand(26)).chr }.join.downcase
    [name, rnd].compact.join('-')
  end
end
