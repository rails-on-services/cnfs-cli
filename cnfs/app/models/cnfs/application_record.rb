# frozen_string_literal: true
require 'active_record'

class Cnfs::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
