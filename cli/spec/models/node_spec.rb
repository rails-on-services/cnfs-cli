# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# ubocop:disable Lint/Debugger
RSpec.describe 'Node' do
  describe '1_users' do
    let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/node/1_users') }

    before do
      CnfsCli.run!(path: path, load_nodes: false) do
        stub_project
        Cnfs.setup(data_store: true, model_names: CnfsCli.model_names)
        Node.with_asset_callbacks_disabled do
          _n = Node::Component.create(path: 'project.yml', owner_class: Project) # , dir_path: 'config')
        end
      end
    end

    it 'creates the correct number of Nodes' do
      expect(Node.count).to eq(7)
    end

    it 'creates the correct number of Components' do
      expect(Component.count).to eq(1)
    end

    it 'creates the correct number of Providers' do
      expect(Provider.count).to eq(1)
    end

    it 'creates the correct number of Users' do
      expect(User.count).to eq(2)
    end
  end

  describe '1_target' do
    let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/node/1_target') }

    before do
      CnfsCli.run!(path: path, load_nodes: false) do
        Cnfs.setup(data_store: true, model_names: CnfsCli.model_names)
        Node.with_asset_callbacks_disabled do
          _n = Node::Component.create(path: 'project.yml', owner_class: Project) # , dir_path: 'config')
        end
      end
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
