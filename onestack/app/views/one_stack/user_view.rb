# frozen_string_literal: true

module OneStack
  class UserView < ApplicationView
    def modify
      %i[name full_name role].each { |attr| ask_attr(attr) }
      ask_hash(:tags)
    end
  end
end
