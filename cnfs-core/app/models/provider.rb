# frozen_string_literal: true

class Provider < ApplicationRecord
  def credentials; options_hash(:credentials) end
  def kubernetes; options_hash(:kubernetes) end
  def storage; options_hash(:storage) end
  def mq; options_hash(:mq) end
end
