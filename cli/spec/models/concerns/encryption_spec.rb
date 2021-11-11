# frozen_string_literal: true

RSpec.shared_examples_for 'encrypted' do
  it 'decrypts all attrs' do
    rf = subject.class.new(subject.parent.yaml)
    rf.valid?
    expect(subject.as_json).to eq(rf.as_json)

    # TODO: When encrypted yaml remains unchnaged when saving back then enable this expectation
    # expect(subject.as_json_encrypted).to eq(rf.as_json_encrypted)
  end
end
