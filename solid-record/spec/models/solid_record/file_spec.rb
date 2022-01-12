# frozen_string_literal: true

require 'pry'
require_relative '../../../lib/solid_record'

RSpec.describe 'File' do
  before(:each) do
    SolidRecord::DataStore.new(model_dirs: 'app/models').setup
    SolidRecord::Directory.create(path: 'spec/fixtures')
  end

  describe 'count' do
    it 'creates the correct number of Files' do
      file_count = Pathname.new('spec/fixtures').glob('**/*').select(&:file?).size
      expect(SolidRecord::File.count).to eq(file_count)
    end
  end
end
