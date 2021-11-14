# frozen_string_literal: true

class ApplicationView < Cnfs::ApplicationView
  def self.index
    view = new
    object = view.select('Choose your destiny?', model_class.all.map(&:name))
    model_class.find_by(name: object)&.edit
  end

  def self.model_class
    @model_class ||= name.gsub('View', '').constantize
  end
end
