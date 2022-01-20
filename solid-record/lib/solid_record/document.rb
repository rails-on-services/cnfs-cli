# frozen_string_literal: true

module SolidRecord
  class Document < ActiveRecord::Base
    include SolidRecord::Table
    self.table_name_prefix = 'solid_record_'

    # belongs_to :parent, class_name: 'Document'
    belongs_to :data_path

    has_many :elements
    # has_many :models, through: :elements, source_type: 'Element'
    def models() = elements.map(&:model)

    after_create :load_document

    def load_document
      raise ArgumentError, "Content must be in Key/Value format #{path}" unless formatted_content.instance_of?(Hash)

      formatted_content.each do |key, values|
        # binding.pry if klass_type.eql?('Blog')
        elements.create(klass_type: klass_type, key: key, values: values, type: 'SolidRecord::RootElement')
      end
    end

    def formatted_content = @formatted_content ||= pathname.singular? ? { pathname.name => content } : content

    def pathname() = @pathname ||= Pathname.new(path)

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :path
          t.string :klass_type
          t.string :type
          t.references :data_path
          # t.references :owner, polymorphic: true
        end
      end
    end
  end
end
