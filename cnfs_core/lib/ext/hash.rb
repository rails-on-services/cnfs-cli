# frozen_string_literal: false

class Hash
  def deep_to_o() = JSON.parse(to_json, object_class: OpenStruct)
end
