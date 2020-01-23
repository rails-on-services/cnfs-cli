# frozen_string_literal: true

RSpec.describe '`cnfs application` command', type: :cli do
  it 'executes `cnfs help application` command successfully' do
    output = `cnfs help application`
    expected_output = <<~OUT
      Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
