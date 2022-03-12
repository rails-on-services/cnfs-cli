# frozen_string_literal: true

module SolidRecord
  class << self
    attr_writer :load_paths

    def load_paths() = @load_paths ||= []

    def status = @status || (@status = ActiveSupport::StringInquirer.new(''))

    def status=(value)
      @status = ActiveSupport::StringInquirer.new(value)
    end
  end

  class LoadPath
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations
    attr_accessor :path, :owner, :model_type

    validate :path_exists

    def initialize(**attributes)
      raise "Missing attribute 'path'" unless attributes.key?(:path)

      assign_attributes(**attributes)
      SolidRecord.load_paths << self
    end

    def path_exists
      errors.add(:path, "invalid: '#{path}'") unless pathname.exist?
    end

    def create_element
      unless valid?
        SolidRecord.raise_or_warn(StandardError.new(errors.full_messages.join("\n")))
        return
      end
      make_sandbox if SolidRecord.config.sandbox
      element_class.create(element_attributes)
    end

    def element_class = pathname.directory? ? SolidRecord::Path : SolidRecord::Document

    def element_attributes
      { path: workpath.to_s, owner: (owner.is_a?(Proc) ? owner.call : owner), model_type: model_type }
    end

    def make_sandbox
      workpath.parent.mkpath unless workpath.parent.exist?
      FileUtils.cp_r(pathname, workpath.parent)
    end

    def workpath() = @workpath ||= relpath

    def relpath
      return pathname.realpath unless SolidRecord.config.sandbox
      DataStore.tmp_path.join(pathname.realpath.to_s.delete_prefix('/'))
    end

    # The path provided by the user
    def pathname() = @pathname ||= Pathname.new(path || '')

    class << self
      def load_all
        path_check
        SolidRecord.status = 'loading'
        toggle_callbacks { SolidRecord.load_paths.each(&:create_element) }
        SolidRecord.status = 'loaded'
      end

      def load(**attributes) = toggle_callbacks { new(**attributes).create_element }

      def toggle_callbacks(&block)
        SolidRecord.with_model_element_callbacks do
          SolidRecord.skip_persistence_callbacks(&block)
        end
      end

      def path_check
        SolidRecord.load_paths.each_with_object([]) do |load_path, ary|
          raise "Load Path '#{load_path}' must by of type LoadPath" unless load_path.is_a?(LoadPath)

          if ary.include?(load_path.path)
            SolidRecord.raise_or_warn(StandardError.new("Duplicate LoadPath detected '#{load_path.path}'"))
          end
          ary << load_path.path
        end
      end
    end
  end
end
