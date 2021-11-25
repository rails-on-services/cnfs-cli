# frozen_string_literal: true

class NewGenerator < Thor::Group
  include Thor::Actions
  argument :name

  private

  def source_paths
    [views_path]
  end

  def views_path
    @views_path ||= internal_path.join(assets_path)
  end

  def assets_path
    self.class.name.delete_suffix('Generator').downcase
  end

  def internal_path
    Pathname.new(__dir__)
  end

  def user_path
    CnfsCli.config.data_home
  end
end
