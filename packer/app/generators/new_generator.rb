# frozen_string_literal: true

class NewGenerator < ApplicationGenerator
  argument :name

  def generate
    directory('files', '.')
    copy_file(CnfsPacker.gem_root.join('config/project.yml'), 'config/project.yml')
    append_file('config/project.yml', "name: #{name}\n")
  end

  private

  def internal_path
    Pathname.new(__dir__)
  end
end
