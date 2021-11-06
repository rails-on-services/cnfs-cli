# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Context' do
  let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/context') }
  let(:project) { Project.first }
  let(:a_context) { Context.create(root: project, options: options) }

  before do
    CnfsCli.run!(path: path, load_nodes: true) do
      _n = Node::Component.create(path: 'project.yml', owner_class: Project)
    end
  end

  describe 'stack: :wrong' do
    let(:options) { { stack: :wrong } }

    it 'generates the correct number of contexts and context_components' do
      a_context
      expect(Context.count).to eq(1)
      expect(ContextComponent.count).to eq(1)
    end

    it 'generates the correct number of providers' do
      expect(a_context.providers.count).to eq(3)
    end
  end

  describe 'stack: :backend, environment: :production, target: :lambda' do
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

  describe 'stack: :frontend, target: :s3' do
    let(:options) { { stack: :frontend, target: :s3 } }

    it 'generates the correct number of contexts and context_components' do
      a_context
      expect(Context.count).to eq(1)
      expect(ContextComponent.count).to eq(2)
    end
  end
end
# rubocop:enable Metrics/BlockLength
