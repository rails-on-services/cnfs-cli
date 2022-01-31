# frozen_string_literal: true

require 'hendrix'
# module Hendrix
#   class Extension
#     ABSTRACT_EXTENSIONS = %w[OneStack::Extension OneStack::Plugin OneStack::Application Hendrix::Extension Hendrix::Plugin Hendrix::Application].freeze
#   end
# end
require 'solid-record'

require 'one_stack/version'
require 'one_stack/application'
require 'one_stack/plugin'
require 'one_stack/extension'

module OneStack
  # module Concerns; end
  # module Crud; end
  # module Images; end
  # module Main; end
  # module Plans; end
  # module Projects; end
  # module Repositories; end
  # module Resources; end
  # module Segments; end
  # module Services; end

  # module Blueprint; end

  class << self
    # The model class list for which tables will be created in the database
    def model_names() = @model_names ||= (asset_names + component_names + support_names).map(&:singularize).freeze

    def asset_names() = @asset_names ||= (operator_names + target_names + generic_names).freeze

    def operator_names() = %w[builders configurators provisioners runtimes]

    def target_names() = %w[images plans playbooks services]

    def generic_names() = %w[dependencies providers resources registries repositories users]

    def component_names() = %w[component segment_root]

    def support_names() = %w[context definitions context_component node cnfs/node runtime_service provisioner_resource]
  end
end
