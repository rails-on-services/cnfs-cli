# frozen_string_literal: true

module SolidRecord
  class ContentError < StandardError; end

  class Document < ActiveRecord::Base
    include SolidRecord::Table

    self.table_name_prefix = 'solid_record_'

    belongs_to :data_path

    # The optional model instance that is the owner of RootElement(s) in this Document
    belongs_to :model, polymorphic: true

    has_many :elements

    validates :path, :type, :klass_type, presence: true

    after_create :load_document

    def load_document
      raise ContentError, "Content must be in Key/Value format #{path}" unless formatted_content.instance_of?(Hash)

      formatted_content.each do |key, values|
        # binding.pry if klass_type.eql?('OneStack')
        elements.create(klass_type: klass_type, key: key, values: values, owner: model,
                        type: 'SolidRecord::RootElement')
      end
    end

    def formatted_content() = @formatted_content ||= pathname.singular? ? { pathname.name => read } : read

    def pathname() = @pathname ||= Pathname.new(path)

    # If the pathname is singular then return the first element name, otherwise return nil
    def root_element() = pathname.singular? ? elements.first : nil

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :data_path
          t.string :path
          t.string :type
          t.string :klass_type
          t.references :model, polymorphic: true
        end
      end
    end
  end
end
