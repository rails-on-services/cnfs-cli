# frozen_string_literal: true

module OneStack
  class ImagesController < ApplicationController
    # around_execute :timer

    def execute(cmd = command)
      context.images.filter_by(args).with_tags(options.tags).group_by(&:builder).each do |builder, images|
        builder.execute(cmd.to_sym, images: images)
      end
    end

    def test
      binding.pry
      execute(:build) if context.options.build
      execute(:test)
    end
  end
end
