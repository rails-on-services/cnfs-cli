# frozen_string_literal: true

require 'cnfs/commands/application/backend'

RSpec.describe Cnfs::Commands::Application::Backend do
  it 'executes `application backend` command successfully' do
    output = StringIO.new
    options = {}
    command = Cnfs::Commands::Application::Backend.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
