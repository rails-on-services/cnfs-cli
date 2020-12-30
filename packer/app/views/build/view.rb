# frozen_string_literal: true

class Build::View < ApplicationView
  def edit
    model_ask(:disk_size, convert: :integer)
  end

  def model_ask(title, **options)
    return ask(title.to_s.humanize, **options) unless model.respond_to?(title)

    value = ask(title.to_s.humanize, value: model.send(title).to_s, **options)
    model.send("#{title}=", value)
  end
end
