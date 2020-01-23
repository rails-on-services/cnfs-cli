# frozen_string_literal: true

RSpec.describe '`cnfs console` command', type: :cli do
  it 'executes `cnfs help console` command successfully' do
    output = `cnfs help console`
    expected_output = <<~OUT
      Usage:
        cnfs console

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
