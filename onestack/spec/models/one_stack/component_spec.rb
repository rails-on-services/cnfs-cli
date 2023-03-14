# frozen_string_literal: true

# require "#{ENV['SPEC_DIR']}/models/concerns/encryption_spec.rb"
# require "#{ENV['SPEC_DIR']}/models/concerns/interpolation_spec.rb"

# rubocop:disable Metrics/BlockLength
module OneStack
  RSpec.describe Component, type: :model do
    let(:segments_yml) { SPEC_PATH.join('dummy/config/segments/component.yml') }
    let(:segments_path) { SPEC_PATH.join('dummy/segments/component') }
    let(:segment_root) { OneStack::SegmentRoot.first }
    # let(:a_context) { Context.create(root: project, options: options) }

    before(:each) do
      OneStack::SpecHelper.setup_segment(self)
      SolidRecord::DataStore.reset(*[
        { path: segments_yml.to_s, model_type: 'OneStack::SegmentRoot' },
        { path: segments_path.to_s, owner: -> { segment_root } }
      ])
    end

    describe 'has_many associations count' do
      context 'components' do it { expect(segment_root.components.count).to eq(3) } end
      context 'dependencies' do it { expect(segment_root.dependencies.count).to eq(6) } end
      context 'providers' do it { expect(segment_root.providers.count).to eq(5) } end
      context 'resources' do it { expect(segment_root.resources.count).to eq(0) } end
      context 'runtimes' do it { expect(segment_root.runtimes.count).to eq(1) } end
      context 'users' do it { expect(segment_root.users.count).to eq(1) } end
    end

    xdescribe '#encryption_key' do
      it { expect(segment_root.encryption_key).to eq(OneStack.config.project_id) }
    end

    describe '#segments_names' do
      it { expect(segment_root.segment_names).to eq(%w[backend doc frontend])}
    end

    describe '#struct' do
      it { binding.pry }
    end
  end
end
# rubocop:enable Metrics/BlockLength
