# frozen_string_literal: true

class ApplicationRecord < Cnfs::ApplicationRecord
  self.abstract_class = true

  # by default rails does not serialize the type field
  def as_json
    super.merge(type_json).except(*except_json)
  end

  def type_json
    has_attribute?(:type) ? { 'type' => type } : {}
  end

  def except_json
    %w[id name owner_type owner_id context_id]
  end
end
