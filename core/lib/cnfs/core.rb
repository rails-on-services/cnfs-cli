# frozen_string_literal: true

require 'cnfs/core/version'
require 'cnfs/core/plugin'

module Core
  module Concerns
    module Cnfs; end
  end
end

module Concerns; end
module Crud; end
module Images; end
module Main; end
module Plans; end
module Projects; end
module Repositories; end
module Resources; end
module Segments; end
module Services; end

module Blueprint; end

module Cnfs
  module Core
    class << self
      # The model class list for which tables will be created in the database
      def model_names() = @model_names ||= (asset_names + component_names + support_names).map(&:singularize).freeze

      def asset_names() = @asset_names ||= (operator_names + target_names + generic_names).freeze

      def operator_names() = %w[builders configurators provisioners runtimes]

      def target_names() = %w[images plans playbooks services]

      def generic_names() = %w[dependencies providers resources registries repositories users]

      def component_names() = %w[component segment_root]

      def support_names() = %w[context definitions context_component node cnfs/node runtime_service provisioner_resource]

      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
    end
  end
end
