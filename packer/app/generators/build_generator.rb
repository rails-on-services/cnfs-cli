# frozen_string_literal: true

class BuildGenerator < ApplicationGenerator
  argument :name

  def generate
    puts 'build controller generate'
    # binding.pry
  end

  private

  def internal_path
    Pathname.new(__dir__)
  end
end
