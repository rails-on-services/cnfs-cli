# frozen_string_literal: true

module SolidRecord
  RSpec.describe Segment do
    before { SolidRecord.setup }

    describe '#flagged_for' do
      context 'when segment is updated' do
        let(:element) { described_class.create(flags: Set.new << :update) }

        before { element }

        it { expect(described_class.flagged.count).to eq(1) }

        it { expect(described_class.flagged_for(:update).count).to eq(1) }

        it { expect(described_class.flagged_for(:destroy).count).to eq(0) }
      end
    end
  end
end
