# frozen_string_literal: true

class Cnfs::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def create
    view.create
    # binding.pry
    save
    # update(attributes)
    self
  end

  def edit
    view.edit
    update(attributes)
    self
  end

  # Return an instance of the view class with a reference to the current model instance
  def view
    self.class.view_class.new(model: self)
  end

  class << self
    # Invoke the view's class method index
    def index
      view_class.index
    end

    # Return the model's view, e.g. ProjectView for Project model
    def view_class
      if (klass = "#{name}View".safe_constantize)
        return klass
      end
      self::View
    end
  end
end
