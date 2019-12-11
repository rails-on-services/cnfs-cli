# frozen_string_literal: true

class Resource::Redis < Resource
  store :config, accessors: %i[clusters], coder: YAML

  def clusters
    super.each_pair do |k, v|
      v['name'] = 'test'
    end
  end
end
