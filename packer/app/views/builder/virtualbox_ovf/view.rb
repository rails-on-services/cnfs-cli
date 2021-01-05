# frozen_string_literal: true

class Builder::VirtualboxOvf::View < Cnfs::TTY::Prompt
  include ViewHelper

  # prompt refers to an instance of Cnfs::TTY::Prompt::AnswersCollector
  def create
    prompt.key(:headless).yes?('Headless?')
  end

  def update
    if build_sources.any?
      name = prompt.key(:builder).enum_select('Source Builder:', build_sources)
      prompt.answer_set(:builder, model.build.builders.find_by(name: name))
    end
    prompt.key(:headless).ask('Headless?', value: model.headless.to_s, convert: :boolean)
  end

  def build_sources
    @build_sources ||= model.build.builders.pluck(:name) - [model.name]
  end
end
