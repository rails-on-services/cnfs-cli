# frozen_string_literal: true

class Cnfs::ApplicationGenerator < Thor::Group
  include Thor::Actions

  private

  def source_paths
    [views_path, views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join(generator_type)
  end

  def generator_type
    self.class.name.demodulize.delete_suffix('Generator').underscore
  end

  def internal_path
    raise NotImplementedError
  end
end
