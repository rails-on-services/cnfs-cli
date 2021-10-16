# frozen_string_literal: true

# require 'cnfs/commands/console'

RSpec.describe 'Cnfs::Commands::Console' do
  xit 'executes `console` command successfully' do
    output = StringIO.new
    options = {}
    # command = Cnfs::Commands::Console.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
