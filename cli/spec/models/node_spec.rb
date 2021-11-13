# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# ubocop:disable Lint/Debugger
RSpec.describe 'Node' do
  describe '1_users' do
    let(:source_path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/node/1_users') }
    let(:path) { source_path.join('../tmp') }

    before do
      path.rmtree if path.exist?
      FileUtils.cp_r(source_path, path)
      CnfsCli.run!(path: path, load_nodes: false) do
        stub_project
        Cnfs.setup(data_store: true, model_names: CnfsCli.model_names)
        Node.with_asset_callbacks_disabled do
          Node::Component.create(path: 'project.yml', owner_class: Project)
        end
      end
    end

    after do
      path.rmtree
    end

    it 'creates the correct number of Nodes' do
      expect(Node.count).to eq(10)
    end

    it 'creates the correct number of Components' do
      expect(Component.count).to eq(1)
    end

    it 'creates the correct number of Providers' do
      expect(Provider.count).to eq(1)
    end

    it 'creates the correct number of Providers' do
      expect(Resource.count).to eq(0)
    end

    it 'creates the correct number of Repositories' do
      expect(Repository.count).to eq(2)
    end

    it 'creates the correct number of Users' do
      expect(User.count).to eq(2)
    end

    it 'updates the User AssetGroup yaml when a new User is created' do
      name = 'test'
      expect(User.count).to eq(2)

      node = node_select('AssetGroup', 'users')
      diff = node_diff(node) { User.create(owner: Project.first, name: name) }

      expect(diff.keys_added.size).to eq(1)
      expect(diff.keys_added.first).to eq(name)
      expect(User.count).to eq(3)
    end

    it 'creates a new AssetGroup when the first Resource is created' do
      name = 'test'
      Dir.chdir(path) do
        expect(Resource.count).to eq(0)
        Resource.create(owner: Project.first, name: name)
        node = Node::AssetGroup.all.select { |n| n.node_name.eql?('resources') }.first
        expect(node.yaml.keys.first).to eql(name)
        expect(Resource.count).to eq(1)
        expect(Node.count).to eq(12)
      end
    end

    it 'deletes an Asset from an AssetGroup' do
      name = 'joe'
      node = node_select('AssetGroup', 'users')
      diff = node_diff(node) { User.find_by(name: name).destroy }

      expect(diff.keys_removed.size).to eq(1)
      expect(diff.keys_removed.first).to eq(name)
      expect(User.count).to eq(1)
      expect(Node.count).to eq(9)
    end

    it 'deletes an AssetGroup and its file when all Assets are destroyed' do
      node = node_select('AssetGroup', 'users')
      expect(node.rootpath.exist?).to be_truthy

      User.all.each(&:destroy)

      expect(User.count).to eq(0)
      expect(Node.count).to eq(7)
      expect(node.rootpath.exist?).to be_falsey
    end

    it 'deletes an Asset from an AssetDir' do
      name = 'kpop'
      Repository.find_by(name: name).destroy

      expect(Repository.count).to eq(1)
      expect(Node.count).to eq(9)
    end

    it 'deletes an AssetDir and its directory when all Assets are destroyed' do
      node = node_select('AssetDir', 'repositories')
      expect(node.rootpath.exist?).to be_truthy

      Repository.all.each(&:destroy)

      expect(Repository.count).to eq(0)
      expect(Node.count).to eq(7)
      expect(node.rootpath.exist?).to be_falsey
    end
  end

  def node_select(klass, name)
    "Node::#{klass}".constantize.all.select { |n| n.node_name.eql?(name) }.first
  end

  def node_diff(node, &block)
    before_yaml = node.yaml
    Dir.chdir(path, &block)
    after_yaml = node.yaml(reload: true)
    keys_added = after_yaml.keys - before_yaml.keys
    keys_removed = before_yaml.keys - after_yaml.keys
    OpenStruct.new(before_yaml: before_yaml, after_yaml: after_yaml, keys_removed: keys_removed, keys_added: keys_added)
  end

  xdescribe '1_target' do
    let(:source_path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/node/1_target') }
    let(:path) { source_path.join('../tmp') }

    before do
      path.rmtree if path.exist?
      FileUtils.cp_r(source_path, path)
      CnfsCli.run!(path: path, load_nodes: false) do
        stub_project
        Cnfs.setup(data_store: true, model_names: CnfsCli.model_names)
        Node.with_asset_callbacks_disabled do
          Node::Component.create(path: 'project.yml', owner_class: Project)
        end
      end
    end

    after do
      path.rmtree
    end

    it 'creates the correct number of Nodes' do
      expect(Node.count).to eq(22)
    end

    it 'creates the correct number of Components' do
      expect(Component.count).to eq(3)
    end

    it 'creates the correct number of Providers' do
      expect(Provider.count).to eq(3)
    end

    it 'creates the correct number of Provisioners' do
      expect(Provisioner.count).to eq(2)
    end

    it 'creates the correct number of Repositories' do
      expect(Repository.count).to eq(2)
    end

    it 'creates the correct number of Repositories' do
      expect(Resource.count).to eq(2)
    end

    it 'creates the correct number of Runtimes' do
      expect(Runtime.count).to eq(2)
    end

    it 'creates the correct number of Users' do
      expect(User.count).to eq(1)
    end
  end
end
# ubocop:enable  Lint/Debugger
# rubocop:enable Metrics/BlockLength
