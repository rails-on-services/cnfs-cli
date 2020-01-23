# frozen_string_literal: true

RSpec.describe '`cnfs application backend` command', type: :cli do
  it 'executes `cnfs application help backend` command successfully' do
    output = `cnfs application help backend`
    expected_output = <<~OUT
      Usage:
        cnfs backend

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
