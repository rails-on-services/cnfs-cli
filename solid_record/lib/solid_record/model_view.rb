# frozen_string_literal: true

module SolidRecord
  class ModelView < TTY::Prompt
    attr_accessor :model, :models, :action

    # @model is for methods that take a single model: create, show, destroy and edit
    # @models is for methods that take an array of models: list
    def initialize(**options)
      @model = options.delete(:model)
      @models = options.delete(:models)
      super(**SolidRecord.config.view_options.merge(options))
    end

    def create
      raise Error, 'Need to pass a model. this is a bug' unless model
      raise Error, 'Create can only be called on new instances' if model.persisted?

      @action = :create

      modify
      if model_has_sti?
        self.model = model_sti_class.new(model.attributes)
        modify_type
      end
      save
    end

    def model_has_sti?() = model_class.has_attribute?(model_class.inheritance_column)

    def model_sti_class() = model.send(model_class.inheritance_column).safe_constantize

    def modify_type
      view_class_name = "#{model_class.inheritance_column}View"
      view_class = view_class_name.safe_constantize
      raise Error, "#{view_class_name} not found. This is a bug. Please report." unless view_class

      view_class.new(view_class_options).modify
    end

    def view_class_options() =  { model: model, models: models }

    def show() = puts(model&.as_json)

    def destroy
      model&.destroy if ask('Are you sure?')
    end

    def edit
      raise Error, 'Need to pass a model. this is a bug' unless model
      raise Error, 'Edit can only be called on existing instances' unless model.persisted?

      @action = :edit

      modify
      save
    end

    def modify() = raise(NotImplementedError, "#{self.class.name} needs to implement #modify")

    def save
      if model.valid?
        model.save
      else
        puts '', 'Not saved due to errors:', model.errors.full_messages
      end
    end

    def list(action = nil)
      return if list_items.empty?

      if action.nil?
        puts list_items
        return
      end
      item = list_items.first if list_items.size.eql?(1)
      item ||= enum_select_val("Select #{model_class_name.demodulize}", choices: list_items)
      # TODO: There is a bug that if two or more models have the same value for 'attribute' it will only
      # return the first one. Use a where in and present a secondary list or another attribute to filter by
      send(action) if (@model = models.find_by(list_attribute => item))
    end

    def select_type
      return if available_types.empty?

      type = available_types.size.eql?(1) ? available_types.first : enum_select_val(:type, choices: available_types)
      model.type = "#{type}::#{model.class.name}"
    end

    def available_types() = @available_types ||= model_class.subclasses.map(&:to_s).map(&:deconstantize)

    def list_items() = @list_items ||= models&.map{ |m| m.send(list_attribute) } || []

    # Override to display a different model attribute
    def list_attribute = :name

    def model_class() = model_class_name.constantize

    def model_class_name() = self.class.name.delete_suffix('View')

    def options() = {} #  'edit' => true } # context.options


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
end
