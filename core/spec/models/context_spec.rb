# frozen_string_literal: true

RSpec.describe 'Context' do
  let(:source_path) { SPEC_DIR.join('fixtures/segments') }
  let(:root) { SegmentRoot.first }
  let(:subject) { Context.create(root: root, options: options) }

  before do
    setup_project(segment: :context)
  end

  after do
    remove_project
  end

  describe 'stack: :frontend' do
    let(:options) { { stack: :frontend } }

    it 'creates the correct number of Nodes' do
      # binding.pry
      expect(Node.count).to eq(57)
    end
  end

  describe 'stack: :wrong' do
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
