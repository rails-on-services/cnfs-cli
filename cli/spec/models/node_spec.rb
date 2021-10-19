# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Lint/Debugger
RSpec.describe 'Node' do
  describe '1_users' do
    let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/1_users') }
    # let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/1_target') }

    before do
      # CnfsCli.run!(path: path, load_nodes: true)
      CnfsCli.run!(path: path, load_nodes: false) do
        _n = Node::Component.create(path: 'project.yml', owner_class: Project)
        # _p = Context.
        # binding.pry
      end
    end

    it 'creates the correct number of Nodes' do
      # binding.pry
      expect(Cnfs.config.orders[0]).to eq('projects')
      [
        { klass: User, count: 2, owner: Project.first }
      ].each do |asset|
        expect(asset[:klass].count).to eq(asset[:count])
        expect(asset[:klass].first.owner).to eq(asset[:owner])
      end
    end
  end

  describe '1_target' do
    let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/1_target') }

    before do
      ENV['CNFS_TAR'] = 'test'
      CnfsCli.reload(path: path)
      CnfsCli.run!(path: path, load_nodes: true) # do
      # _n = Node::Component.create(path: 'project.yml', asset_class: Project)
      # end
    end

    # xit 'creates the correct number of nodes' do
    #   Node.skip_callback(:create, :after, :load_search_paths)
    #   n = Node.create(path: 'spec/fixtures/project_1/project.yml', asset_type: 'project')
    #   expect(Node.count).to eq(1)
    # end

    it 'creates the correct number of Assets' do
      expect(Cnfs.config.orders[0]).to eq('projects')
      [
        { klass: Builder, count: 3, owner: Project.first },
        { klass: Context, count: 1, owner: Project.first },
        { klass: Provider, count: 3, owner: Project.first },
        { klass: Repository, count: 2, owner: Project.first },
        { klass: Runtime, count: 2, owner: Project.first },
        { klass: User, count: 1, owner: Project.first }
      ].each do |asset|
        expect(asset[:klass].count).to eq(asset[:count])
        expect(asset[:klass].first.owner).to eq(asset[:owner])
      end

      expect(Component.count).to eq(2)

      # it 'creates the correct number of Components' do
      # [
      #   { klass: Target, count: 1, ref: :project, owner: Project.first }
      # ].each do |component|
      #   expect(component[:klass].count).to eq(component[:count])
      #   # expect(component[:klass].first.send(component[:ref])).to eq(component[:owner])
      #   expect(component[:klass].first.owner).to eq(component[:owner])
      # end
      binding.pry
    end
  end

  # describe 'create' do
  #   xit 'creates the correct number of nodes' do
  #     _n = Node.create(path: 'spec/fixtures/project_1/project.yml', asset_type: 'project')
  #     expect(Node.count).to eq(Dir.glob('spec/fixtures/project_1/**/*').size)
  #     binding.pry
  #   end
  #
  #   describe 'type' do
  #     xit 'correctly identifies a single resource' do
  #       type = tree.nodes['spec/fixtures/config'].nodes['backend'].nodes['development']
  #       .nodes['resources'].nodes['cap4.yml'].type
  #     end
  #   end
  # end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable  Lint/Debugger
