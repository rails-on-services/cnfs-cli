# frozen_string_literal: true

class ApplicationRecord < Cnfs::ApplicationRecord
  self.abstract_class = true

  # _source is set by parse for existing configurations
  # _source needs to be set when saving a new object, but not written to the file
  # TODO: This should take into account Cnfs.context rather than just Cnfs.project.paths.config
  def save_path
    @save_path ||= begin
    # _source ? Pathname.new(_source) : super
      bpath = _source ? Pathname.new(_source) : Cnfs.project.paths.config.join("#{self.class.table_name}.yml")
      Cnfs.project_root.join(bpath)
                   end
  end

  def combine(runtime: false)
    like_me = self.class.where(name: name)
    new_one = like_me.each_with_object({}) { |record, hash| hash.deep_merge!(record.as_save) }
    new_one.merge!(context: :runtime) if runtime
    self.class.create(new_one)
  end
end
