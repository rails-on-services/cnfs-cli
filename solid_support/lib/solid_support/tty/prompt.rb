# frozen_string_literal: true

# NOTE: This one is not currently in use
module SolidSupport::TTY
  class Prompt < TTY::Prompt
    attr_accessor :model, :prompt

    def initialize(**options)
      @model = options.delete(:model)
      @prompt = options.delete(:prompt)
      super(**options.merge(default_options))
    end

    def default_options
      { help_color: :cyan }
    end

    def p_ask(key, title: nil, value: nil, **options)
      value ||= model.send(key)
      prompt.key(key).ask("#{title || key.to_s.humanize}:", **modified_options(key, value, **options))
    end

    def p_enum_select(key, title: nil, value: nil, choices: [], **options)
      value ||= model.send(key)
      # modified_options(key, value, **options)
      prompt.key(key).enum_select("#{title || key.to_s.humanize}:", choices, **options) do |menu|
        menu.default(value) if value
      end
    end

    def p_select(key, title: nil, value: nil, choices: [], **options)
      value ||= model.send(key)
      # modified_options(key, value, **options)
      prompt.key(key).select("#{title || key.to_s.humanize}:", choices, **options) do |menu|
        menu.default(value) if value
      end
    end

    def p_multi_select(key, title: nil, values: nil, choices: [], **options)
      values ||= model.send(key).map(&:to_s)
      prompt.key(key).multi_select("#{title || key.to_s.humanize}:", choices.map(&:to_s), **options) do |menu|
        menu.default(*values) if values.any?
      end
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def modified_options(key, value, **options)
      if value.is_a?(Array)
        value = value.join(', ')
        options[:convert] = :array
      end
      value = (value || '').to_s if options.key?(:convert) && options[:convert].eql?(:boolean)
      options[:value] = value if value
      required = model.class.validators_on(key).count do |v|
        v.is_a?(ActiveRecord::Validations::PresenceValidator)
      end.positive?
      options[:required] = true if required
      options
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def next?(type)
      next_record(type, take: false)
    end

    def next_record(type, take: true)
      name = "@#{type}"
      taken_name = "@#{type}_taken"
      records = instance_variable_get(name) || instance_variable_set(name, record_set(model.send(type)).each)
      taken = instance_variable_get(taken_name) || instance_variable_set(taken_name, 0)
      return taken < records.size unless take

      return if taken.eql?(records.size)

      instance_variable_set(taken_name, taken + 1)
      # binding.pry
      records.next
    end

    # Override this method to modify the query of returned rows; e.g. base.order(:column_name)
    def record_set(base)
      base
    end

    # rubocop:disable Metrics/AbcSize
    def collect_model(**options, &block)
      # Original code from TTY::Prompt#collect
      collector = AnswersCollector.new(self, **options)
      ret_val = collector.call(&block)

      # Added code to return a model with associations
      association_names = model.class.reflect_on_all_associations(:has_many).map(&:name)
      association_names.select { |name| ret_val.key?(name) }.each do |name|
        klass = name.to_s.classify.safe_constantize
        ret_val[name].map! { |params| klass.new(params.merge(model.class.name.underscore => model)) }
        # binding.pry
      end
      model.assign_attributes(ret_val)
      model
    end
    # rubocop:enable Metrics/AbcSize
  end
end
