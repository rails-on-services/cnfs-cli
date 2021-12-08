# frozen_string_literal: true

module Images
  class BuildController
    include ExecHelper

    def build() = context.image_builders.each { |builder| builder.execute(:build) }

    def push() = context.image_builders.each { |builder| builder.execute(:push) }

    def pull() = context.image_builders.each { |builder| builder.execute(:pull) }

    def test() = context.image_builders.each { |builder| builder.execute(:test) }
  end
end
