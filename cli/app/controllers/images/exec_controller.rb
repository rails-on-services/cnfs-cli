# frozen_string_literal: true

module Images
  class ExecController
    include Concerns::ExecController

    around_execute :timer

    def build() = context.image_builders.each { |builder| builder.execute(:build) }

    def push() = context.image_builders.each { |builder| builder.execute(:push) }

    def pull() = context.image_builders.each { |builder| builder.execute(:pull) }

    def test
      build if context.options.build
      context.image_builders.each { |builder| builder.execute(:test) }
    end
  end
end
