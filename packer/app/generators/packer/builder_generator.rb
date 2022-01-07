# frozen_string_literal: true

class Packer::BuilderGenerator < BuilderGenerator
  argument :build

  def generate
    build.builders.each { |pp| pp.template(self) }
    build.provisioners.each { |pp| pp.template(self) }
    build.post_processors.each { |pp| pp.template(self) }
  end

  private

  def internal_path() = Pathname.new(__dir__)
end
