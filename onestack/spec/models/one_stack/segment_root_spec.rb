# frozen_string_literal: true

module OneStack
  RSpec.describe SegmentRoot, type: :model do
    # it_behaves_like 'encryption'
    # it_behaves_like 'interpolate'
    let(:segments_yml) { SPEC_PATH.join('dummy/config/segments/context.yml') }
    let(:segments_path) { SPEC_PATH.join('dummy/segments/context') }
    let(:segment_root) { SegmentRoot.first }
    # let(:a_context) { Context.create(root: root, options: options) }

    before(:each) do
      SpecHelper.setup_segment(self)
      SolidRecord::DataStore.reset(*[
        { path: segments_yml.to_s, model_type: 'OneStack::SegmentRoot' },
        { path: segments_path.to_s, owner: -> { OneStack::SegmentRoot.first } }
      ])
    end

    context 'when stack: :wrong' do
      let(:options) { { stack: :backend, environment: :production, target: :lambda } }
      # let(:options) { { stack: :wrong } }

      it { binding.pry }
      # it 'generates the correct number of contexts and context_components' do
      it { expect(Context.count).to eq(1) }
      it { expect(ContextComponent.count).to eq(3) }
    end
  end
end
