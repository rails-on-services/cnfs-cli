# frozen_string_literal: true

require 'tty-prompt'
require 'tty-tree'

class Cnfs::ApplicationView < TTY::Prompt
  def default_options() = { help_color: :cyan }

  # Set an attribute from a Prompt.select result
  #
  # ==== Examples
  # view_select(:instance_family, model.offers_by_family, model.family)
  #
  # ==== Parameters
  # title<String>:: The title text to display to the user. If it is also an attribute of the object ti will be set
  # data<Array>:: An array of data to be presented to the user as a select list
  # current<String>:: The default value in the Array
  def select_attr(key, title: nil, default: nil, choices: [], **options)
    default ||= model.send(key)
    ret_val = select_val(key, title: title, default: default, choices: choices, **options)
    model.send("#{key}=", ret_val)
  end

  def select_val(key, title: nil, default: nil, choices: [], **options)
    title ||= key.to_s.humanize

    options[:help] ||= 'Type to filter results'
    options[:filter] ||= true
    options[:per_page] ||= per_page(choices)
    options[:show_help] ||= :always

    select("#{title}:", choices, **options) do |menu|
      # menu.help 'Type to filter results'
      menu.default((choices.index(default) || 0) + 1) if default
      # yield menu if block_given?
    end
  end

  def enum_select_attr(key, title: nil, default: nil, choices: [], **options)
    default ||= model.send(key)
    ret_val = enum_select_val(key, title: title, default: default, choices: choices, **options)
    model.send("#{key}=", ret_val)
  end

  def enum_select_val(key, title: nil, default: nil, choices: [], **options)
    title ||= key.to_s.humanize

    options[:per_page] ||= per_page(choices)

    enum_select("#{title}:", choices, **options) do |menu|
      menu.default(default) if default
    end
  end

  def ask_attr(key, title: nil, **options)
    options[:default] ||= model.send(key)
    ret_val = ask_val(key, title: title, **options)
    model.send("#{key}=", ret_val)
  end

  def ask_val(key, title: nil, **options)
    title ||= key.to_s.humanize
    ask(title, **options)
  end

  def mask_attr(key, title: nil, **options)
    options[:default] ||= model.send(key)
    ret_val = mask_val(key, title: title, **options)
    model.send("#{key}=", ret_val)
  end

  def mask_val(key, title: nil, **options)
    title ||= key.to_s.humanize
    mask(title, **options)
  end

  def yes_attr(key, title: nil, **options)
    options.fetch(:default, model.send(key))
    # binding.pry
    ret_val = yes_val(key, title: title, **options)
    model.send("#{key}=", ret_val)
  end

  def yes_val(key, title: nil, **options)
    title ||= key.to_s.humanize
    # binding.pry
    yes?(title, **options)
  end


  # TODO: Refactor below methods

  def ask_hash(field)
    model.send("#{field}=".to_sym, hv(field))
  end

  def hv(field)
    model.send(field.to_sym).each_with_object({}) do |(key, value), hash|
      hash[key] = ask(key, value: value)
    end
  end

  def per_page(array, buffer = 3)
    [TTY::Screen.rows, array.size].max - buffer
  end

  def random_string(name = nil, length: 12)
    rnd = (0...length).map { rand(65..90).chr }.join.downcase
    [name, rnd].compact.join('-')
  end
end
