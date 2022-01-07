# frozen_string_literal: true

class ApplicationView < Cnfs::ApplicationView
  attr_accessor :model, :models, :context, :component, :action

  # @model is for methods that take a single model: create, show, destroy and edit
  # @models is for methods that take an array of models: list
  # @context is the current context
  def initialize(**options)
    @model = options.delete(:model)
    @models = options.delete(:models)
    @context = options.delete(:context)
    @component = @context.component
    super(**default_options.merge(options))
  end

  def create
    raise Cnfs::Error, 'Need to pass a model. this is a bug' unless model
    raise Cnfs::Error, 'Create can only be called on new instances' if model.persisted?
    @action = :create

    modify
    self.model = model.type.safe_constantize.new(model.attributes) if model.type
    modify_type
    save
  end

  def show() = puts(model&.as_json)

  def destroy
    return unless ask('Are you sure?')

    model&.destroy
  end

  def edit
    raise Cnfs::Error, 'Need to pass a model. this is a bug' unless model
    raise Cnfs::Error, 'Create can only be called on existing instances' unless model.persisted?
    @action = :edit

    modify
    modify_type
    save
  end

  def modify() = raise(NotImplementedError, "#{self.class.name} needs to implement #modify")

  def modify_type
    return unless model.type

    view_klass_name = "#{model.type}View"
    view_klass = view_klass_name.safe_constantize
    raise Cnfs::Error, "#{view_klass_name} not found. This is a bug. Please report." unless view_klass

    view_klass.new(model: model, models: models, context: context).modify
  end

  def save
    if model.valid?
      model.save
    else
      puts '', 'Not saved due to errors:', model.errors.full_messages
    end
  end

  def list
    return unless names.size.positive?

    ret_val = %w[show edit destroy].each do |action|
      if options.keys.include?(action)
        name = names.size.eql?(1) ? names.first : enum_select_val("Select #{model_class_name}", choices: names)
        send(action) if (@model = models.find_by(name: name))
        break nil
      end
    end
    puts names unless ret_val.nil?
  end

  # # TODO: Use TTY-tree to list all envs
  # def list
  #   require 'tty-tree'
  #   data = Environment.order(:name).each_with_object({}) do |env, hash|
  #     hash[env.name] = env.blueprints.pluck(:name)
  #   end
  #   puts data.any? ? TTY::Tree.new(data).render : 'none found'
  # end

  def select_type
    return unless available_types.size.positive?

    type = available_types.size.eql?(1) ? available_types.first : enum_select_val(:type, choices: available_types)
    model.type = "#{type}::#{model.class.name}"
  end

  def available_types() = @available_types ||= model.class.subclasses.map(&:to_s).map(&:deconstantize)

  def names() = models.map(&:name)

  def model_class_name() = self.class.name.delete_suffix('View')

  def options() = context.options

  Cnfs::Core.asset_names.each do |asset_name|
    define_method("#{asset_name.singularize}_names".to_sym) do
      component.send("#{asset_name.singularize}_names".to_sym) 
    end
  end
end
