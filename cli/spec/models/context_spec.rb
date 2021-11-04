# frozen_string_literal: true

RSpec.describe 'Context' do
  describe '1_users' do
    let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/context') }

    before do
      CnfsCli.run!(path: path, load_nodes: true) do
        _n = Node::Component.create(path: 'project.yml', owner_class: Project)
      end
    end

    describe 'create' do
      it 'has the correct number of contexts and context_components' do
        options = { target: :crank }
        pf = Project.first
        ctx = pf.contexts.create(root: pf, options: options)
        # binding.pry
        expect(Context.count).to eq(1)
        expect(ContextComponent.count).to eq(2)
        # options = Thor::CoreExt::HashWithIndifferentAccess.new(stack: 'backend', environment: 'development')
        # c = Context.create(options: options, root: p)
        # binding.pry
        # expect(c.root.name).to eq('test')
     end
    end
  end
end
