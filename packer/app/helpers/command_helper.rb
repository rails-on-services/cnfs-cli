# frozen_string_literal: true

module CommandHelper
  extend ActiveSupport::Concern
  include CnfsCommandHelper

  included do
    extend CnfsCommandHelper
    add_cnfs_option :build, desc: 'Target build',
                            aliases: '-b', type: :string, default: Cnfs.config.build
  end
end
