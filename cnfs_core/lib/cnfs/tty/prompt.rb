# frozen_string_literal: true

module Cnfs::TTY
  class Prompt < TTY::Prompt
    attr_accessor :model, :prompt

    def initialize(**options)
      @model = options.delete(:model)
      @prompt = options.delete(:prompt)
      super(**options.merge(default_options))
    end

    def p_ask(key, title: nil, value: nil, **options)
      d_value = value || model.send(key)
      value_hash = d_value ? { value: d_value } : {}
      prompt.key(key).ask("#{(title || key).to_s.humanize}:", **options.merge(value_hash))
    end

    def default_options
      { help_color: :cyan }
    end

    def has_next?(record_set)
      next_record(record_set, true)
    end

    def next_record(type, noop = false)
      name = "@#{type}"
      taken_name = "@#{type}_taken"
      records = instance_variable_get(name) || instance_variable_set(name, record_set(model.send(type)).each)
      taken = instance_variable_get(taken_name) || instance_variable_set(taken_name, 0)
      return taken < records.size if noop

      return if taken.eql?(records.size)

      instance_variable_set(taken_name, taken + 1)
      records.next
    end

    # Override this method to modify the query of returned rows; e.g. base.order(:column_name)
    def record_set(base)
      base
    end

    def collect_model(**options, &block)
      # Original code from TTY::Prompt#collect
      collector = AnswersCollector.new(self, **options)
      ret_val = collector.call(&block)

      # Added code to return a model with associations
      association_names = model.class.reflect_on_all_associations(:has_many).map(&:name)
      association_names.select { |name| ret_val.keys.include?(name) }.each do |name|
        klass = name.to_s.classify.safe_constantize
        ret_val[name].map! { |params| klass.new(params.merge(model.class.name.underscore => model)) }
      end
      model.assign_attributes(ret_val)
      model
    end
  end
end
