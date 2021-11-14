# frozen_string_literal: true

class UserView < ApplicationView
  def index(_nul)
    user = select('Choose your destiny?', User.all.map(&:name))
    return unless (uv = User.find_by(name: user))

    uv.edit
  end

  def edit
    model.name = ask('name', value: model.name)
    model.full_name = ask('full name', value: model.full_name || '')
    model.role = ask('role', value: model.role || '')
    ask_hash(:tags)
  end
end
