# frozen_string_literal: true

class ApplicationRecord < Cnfs::ApplicationRecord
  self.abstract_class = true

  # by default rails does not serialize the type field
  def as_json
    has_attribute?(:type) ? super.merge('type' => type) : super
  end

  # _source is set by parse for existing configurations
  # _source needs to be set when saving a new object, but not written to the file
  # TODO: This should take into account Cnfs.context rather than just Cnfs.project.paths.config
  def save_path
    binding.pry
    @save_path ||= begin
    # _source ? Pathname.new(_source) : super
      bpath = _source ? Pathname.new(_source) : Cnfs.project.paths.config.join("#{self.class.table_name}.yml")
      Cnfs.project_root.join(bpath)
                   end
  end
end
