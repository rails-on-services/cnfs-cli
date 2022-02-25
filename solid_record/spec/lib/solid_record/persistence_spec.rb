# frozen_string_literal: true

module SolidRecord
  RSpec.shared_examples_for 'Persistence' do
    it { expect(subject).to respond_to(:key_column) }
  end
end
