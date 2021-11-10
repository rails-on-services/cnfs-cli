# frozen_string_literal: true

RSpec.describe 'Project' do
  it_behaves_like 'encryption'
  it_behaves_like 'interpolate'
  let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/context') }
  let(:project) { Project.first }
  let(:a_context) { Context.create(root: project, options: options) }

  before do
    CnfsCli.run!(path: path, load_nodes: true) do
      _n = Node::Component.create(path: 'project.yml', owner_class: Project)
    end
  end

  describe 'stack: :wrong' do
    let(:options) { { stack: :backend, environment: :production, target: :lambda } }
    # let(:options) { { stack: :wrong } }

    it 'generates the correct number of contexts and context_components' do
      a_context
      expect(Context.count).to eq(1)
      expect(ContextComponent.count).to eq(3)
    end
  end
end
