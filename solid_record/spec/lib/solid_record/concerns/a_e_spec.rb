# frozen_string_literal: true

module SolidRecord
  RSpec.shared_examples_for 'AE' do
    let(:valid_path) { described_class.new(model_type: 'test', path: '.') }
    let(:invalid_path) { described_class.new(model_type: 'test', path: 'invalid_path') }
    let(:no_path) { described_class.new(model_type: 'test') }

    it { expect(valid_path).to be_valid }
    it { expect(invalid_path).not_to be_valid }
    it { expect(no_path).to be_invalid }
  end
end
