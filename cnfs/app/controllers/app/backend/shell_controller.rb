# frozen_string_literal: true

module App::Backend
  class ShellController < Cnfs::Command
    def on_execute
      compose(args.service, 'bash')
    end
  end
end
