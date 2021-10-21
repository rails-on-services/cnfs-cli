# frozen_string_literal: true

module ServicesHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper
    include TtyHelper
  end

  # TODO: Should this move to ExecHelper?
  def before_execute
    context.update(args: args)

    unless context.runtime.services.any?
      raise Cnfs::Error, "Service not found #{args.service || args.services.join(' ')}"
    end
  end
end
