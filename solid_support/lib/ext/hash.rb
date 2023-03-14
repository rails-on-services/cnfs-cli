# frozen_string_literal: false

# rubocop:disable Style/OpenStructUse
class Hash
  def deep_to_o() = JSON.parse(to_json, object_class: OpenStruct)
end
# rubocop:enable Style/OpenStructUse
