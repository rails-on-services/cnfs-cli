# frozen_string_literal: true

module ServicesHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper

    around_execute :timer
  end

  def raise_if_runtimes_empty
    return if context.runtimes.any?

    raise Cnfs::Error, "Services not found: #{context.args.service || context.args.services.join(' ')}"
  end
end
