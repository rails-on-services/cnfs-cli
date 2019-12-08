# frozen_string_literal: true

class Runtime::SkaffoldGenerator < ApplicationGenerator

  def generate
    binding.pry
  end

  private

  def internal_path; __FILE__ end
end
