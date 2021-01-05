# frozen_string_literal: true

class Builder::VirtualboxIso::View < Cnfs::TTY::Prompt
  include ViewHelper

  # prompt refers to an instance of Cnfs::TTY::Prompt::AnswersCollector
  def create
    name = prompt.key(:operating_system).enum_select('OS:', OperatingSystem.pluck(:name))
    prompt.answer_set(:operating_system, OperatingSystem.find_by(name: name))
    prompt.key(:disk_size).ask('Disk size:')
    prompt.key(:headless).ask('Headless?', convert: :boolean)
  end

  def update
    # prompt.key(:name).ask('Name:', value: model.name)
    name = prompt.key(:operating_system).enum_select('OS:', OperatingSystem.pluck(:name))
    prompt.answer_set(:operating_system, OperatingSystem.find_by(name: name))
    ask(:disk_size)
    ask(:headless, title: 'Headless?', value: model.headless.to_s, convert: :boolean)
  end

  def ask(key, title: nil, value: nil, **options)
    prompt.key(key).ask("#{(title || key).to_s.humanize}:", value: value || model.send(key), **options)
  end
end
