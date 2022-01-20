# frozen_string_literal: true

module SolidRecord
  RSpec.describe 'Element' do
    before(:each) do
      # Pathname.new('.').glob(ROOT.join('spec/dummy/stack/app/models/*.rb')).each { |path| require_relative path }
      Pathname.new('.').glob(ROOT.join('spec/dummy/infra/app/models/*.rb')).each { |path| require_relative path }
      # Pathname.new('.').glob('../core/app/models/*.rb').each { |path| require_relative path }
      # SolidRecord::DataStore.load
      DataStore.load
      # Dir.chdir(ROOT) do
      # SolidRecord::PathLoader.new(path: 'spec/dummy/stack/data', path_map: 'segments', recurse: true)
      # end
    end

    describe 'count' do
      it 'creates the correct number of Files' do
        file = Pathname.new(ROOT.join('spec/dummy/infra/data/groups.yml'))
        _doc = YamlDocument.new(klass_type: '::Group', path: file)
        # binding.pry
        # file_count = Pathname.new('spec/fixtures').glob('**/*').select(&:file?).size
        # expect(SolidRecord::File.count).to eq(file_count)
      end
    end
  end
end
