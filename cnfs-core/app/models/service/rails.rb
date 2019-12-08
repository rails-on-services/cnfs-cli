# frozen_string_literal: true

class Service::Rails < Service

  def profiles; YAML.load(self[:profiles]) end
end
