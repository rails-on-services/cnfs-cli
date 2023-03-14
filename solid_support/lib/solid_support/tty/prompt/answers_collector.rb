# frozen_string_literal: true

module Hendrix::TTY
  class Prompt::AnswersCollector < TTY::Prompt::AnswersCollector
    def assign_answers(model, *attributes)
      attributes.each do |attribute|
        answer_set(attribute, model.send(attribute))
      end
    end

    def answer_set(name, value = nil)
      @answers[name] = block_given? ? yield(@answers[name]) : value
    end

    def answer_get(name)
      @answers[name]
    end
  end
end
