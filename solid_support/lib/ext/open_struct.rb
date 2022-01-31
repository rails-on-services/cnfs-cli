# frozen_string_literal: false

# rubocop:disable Style/OpenStructUse
class OpenStruct
  def deep_to_h() = to_h.transform_values { |v| v.is_a?(OpenStruct) ? v.deep_to_h : v }.deep_stringify_keys
end
# rubocop:enable Style/OpenStructUse
