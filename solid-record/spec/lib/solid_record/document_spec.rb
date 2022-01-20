# frozen_string_literal: true

module SolidRecord
  RSpec.describe 'Document' do
    before(:all) do
      Pathname.new('.').glob(ROOT.join('spec/dummy/infra/app/models/*.rb')).each { |path| require_relative path }
      DataStore.load
    end

    before(:each) do
      DataStore.reset
      # Pathname.new('.').glob(ROOT.join('spec/dummy/stack/app/models/*.rb')).each { |path| require_relative path }
      # Pathname.new('.').glob('../core/app/models/*.rb').each { |path| require_relative path }
      # Dir.chdir(ROOT) do
      # SolidRecord::DataPath.new(path: 'spec/dummy/stack/data', path_map: 'segments', recurse: true)
      # end
    end

    describe 'monolithic yaml' do
      let(:file) { Pathname.new(ROOT.join('spec/dummy/infra/data/monolith/groups.yml')) }
      
      let(:doc) { SolidRecord.skip_model_callbacks { YamlDocument.create(klass_type: '::Group', path: file) } }

      xit 'creates the correct number of models' do
        expect(::Group.count).to eq(4)
        expect(::Host.count).to eq(11)
        expect(::Service.count).to eq(1)
      end

      xit 'creates the correct model associations' do
        # expect(::Group.find_by(oauth_domain: 'ASC').hosts.count).to eq(6)
      end

      xit 'creates the correct number of Documents and Elements' do
        expect(Document.first.models.size).to eq(4)
        expect(::Host.last.element.root.document).to eq(Document.first)
      end
    end

    # describe 'hierarchial yaml' do
    # end
  end
end
