# frozen_string_literal: true

class UserView < ApplicationView
  def modify
    %i[name full_name role].each { |attr| ask_attr(attr) }
    ask_hash(:tags)
  end
end
