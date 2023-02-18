# frozen_string_literal: true

module SolidRecord
  class Path < Segment
    class << self
      # If invoked from a subclass then just wrap in toggle_callbacks block
      # If invoked on the Path class then first figure out which subclass it should be
      def add(**attributes)
        element_class = name.demodulize.eql?('Path') ? klass(attributes[:source]) : self
        SolidRecord.toggle_callbacks { element_class.create(attributes) }
      end

      def klass(source)
        type = Pathname.new(source.to_s).directory? ? 'DirInstance' : 'File'
        "SolidRecord::#{type}".safe_constantize
      end
    end

    def create_hash = super.merge(root: (source_path? ? self : root), model_class_name: model_class_name)

    # namespace and glob provided by user when creating a Path; defaults to SolidRecord.config values
    store :config, accessors: %i[source status path namespace glob]

    delegate :realpath, :exist?, to: :source_path

    # From FileSystemElement
    delegate :name, to: :pathname

    delegate :write, to: :parent, prefix: true, allow_nil: true
    after_commit :parent_write, on: :destroy, if: -> { parent&.type&.eql?('SolidRecord::Dir') }
    # END: From FileSystemElement

    before_validation :set_path, if: :source_path?

    validate :source_exists, if: :source_path?, on: :create
    validate :source_uniqueness, if: %i[source_path? exist?], on: :create

    before_create :make_sandbox, if: %i[source_path? sandbox?]

    # if this is not the root record then pass to root
    # if it is the root record then get the value from the :config hash
    # if that value is nil then default to config.glob
    def namespace = root&.namespace || super || SolidRecord.config.namespace

    def glob = root&.glob || super || SolidRecord.config.glob

    def set_path
      self.path = (sandbox? ? SolidRecord.tmp_path.join(realpath.to_s.delete_prefix('/')) : realpath).to_s
    end

    def source_exists
      errors.add(:source, 'does not exist') unless exist?
    end

    def source_uniqueness
      self.class.all.each do |lp|
        errors.add(:source, 'already exists') if lp.realpath.to_s.eql?(realpath.to_s)
      end
    end

    def source_path? = !source.nil?

    def sandbox? = SolidRecord.config.sandbox

    def make_sandbox
      pathname.parent.mkpath unless pathname.parent.exist?
      FileUtils.cp_r(realpath, pathname.parent)
    end

    def set_defaults
      self.model_class_name ||= class_map[name.singularize] || pathname.name
    end

    def class_map = SolidRecord.config.class_map

    # def element_attributes
    # { path: workpath.to_s, owner: (owner.is_a?(Proc) ? owner.call : owner) }
    # end

    def pathname = @pathname ||= Pathname.new(path || '')

    def source_path = @source_path ||= Pathname.new(source&.to_s || '')
  end
end
