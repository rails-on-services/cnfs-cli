# frozen_string_literal: true

class Resource::Cert < Resource
  store :config, accessors: %i[subject_alternative_names], coder: YAML

  def subject_alternative_names; super || [] end
end
