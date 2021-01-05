# frozen_string_literal: true

class Builder::VirtualboxIso::View < Cnfs::TTY::Prompt
  include ViewHelper

  # prompt refers to an instance of Cnfs::TTY::Prompt::AnswersCollector
  def create
    name = prompt.key(:operating_system).enum_select('OS:', OperatingSystem.pluck(:name))
    prompt.answer_set(:operating_system, OperatingSystem.find_by(name: name))
    p_ask(:disk_size)
    prompt.key(:headless).ask('Headless?', convert: :boolean)
  end

  def update
    name = prompt.key(:operating_system).enum_select('OS:', OperatingSystem.pluck(:name))
    prompt.answer_set(:operating_system, OperatingSystem.find_by(name: name))
    p_ask(:disk_size)
    p_ask(:headless, title: 'Headless?', value: model.headless.to_s, convert: :boolean)
  end
end
