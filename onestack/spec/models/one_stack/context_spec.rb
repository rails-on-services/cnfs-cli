# frozen_string_literal: true

module OneStack

RSpec.describe 'Context' do
  # let(:source_path) { SPEC_DIR.join('fixtures/segments') }
  # let(:root) { SegmentRoot.first }
  # let(:subject) { Context.create(root: root, options: options) }

  before(:each) do
    OneStack::SpecLoader.setup_segment(self, load_nodes: true)
  end

  after do
    # remove_project
  end

  describe 'frontend' do
    let(:options) { { stack: :frontend } }
    let(:sr) { SolidRecord::DataPath.create(namespace: 'OneStack', path_map: 'segment_root', 
                                            path: APP_ROOT.join('config')) }
    let(:segments) { SolidRecord::DataPath.create(namespace: 'OneStack', path_map: 'segments', 
                                           path: OneStack.config.paths.segments, recurse: true )}

    it 'creates one SegmentRoot' do
      # NOTE: This stuff will move to SolidRecord after it is working so don't get too caught up about how it looks!
      sr.load
      expect(SegmentRoot.count).to eq(1)
    end

    it 'does anotheer' do
      sr.load
      binding.pry
    end
  end

  describe 'wrong' do
    let(:options) { { stack: :wrong } }

    it 'generates the correct number of contexts and context_components' do
      subject
      expect(Context.count).to eq(1)
      binding.pry
      expect(ContextComponent.count).to eq(1)
    end

    it 'generates the correct number of providers' do
      expect(subject.providers.count).to eq(3)
    end
  end

  xdescribe 'stack: :backend, environment: :production, target: :lambda' do
    let(:options) { { stack: :backend, environment: :production, target: :lambda } }

    it 'generates the correct number of contexts and context_components' do
      a_context
      expect(Context.count).to eq(1)
      # binding.pry
      expect(ContextComponent.count).to eq(3)
    end

    it 'generates the correct number of resources' do
      expect(a_context.resources.count).to eq(2)
    end

    it 'generates the correct number of providers' do
      expect(a_context.providers.count).to eq(2)
    end
  end

  xdescribe 'stack: :frontend, target: :s3' do
    let(:options) { { stack: :frontend, target: :s3 } }

    it 'generates the correct number of contexts and context_components' do
      a_context
      expect(Context.count).to eq(1)
      expect(ContextComponent.count).to eq(2)
    end
  end
end
end
