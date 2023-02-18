# frozen_string_literal: true

module SolidRecord
  class Dir < Path
    delegate :children, :rmdir, to: :pathname

    after_create :process_contents

    after_commit :rmdir, on: :destroy

    # def create_hash = super.merge(path: path.to_s)

    def write = segments.count.zero? ? destroy : nil

    def tree_label = "#{name} (#{type.demodulize})"

    def invalid_path(path) = path.to_s.delete_prefix("#{root.pathname.parent}/")

    def msg(assn) = "is not a valid #{assn} association on #{owner.class.name}"
  end
end
