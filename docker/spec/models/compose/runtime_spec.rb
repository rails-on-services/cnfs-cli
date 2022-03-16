# frozen_string_literal: true

module Compose
  RSpec.describe Runtime, type: :model do
    let(:segment_root) { OneStack::SegmentRoot.first }
    let(:nav) { OneStack::Navigator.new }
    let(:context) { nav.context }

    before { OneStack::SpecHelper.setup_segment(self) }

    context 'when stack: :wrong' do
      let(:options) { { stack: :backend, environment: :production, target: :lambda } }
      # let(:options) { { stack: :wrong } }

      it { binding.pry }
    end
  end
end
