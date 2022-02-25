# frozen_string_literal: true

module SolidRecord
  RSpec.describe Element do
    before { DataStore.reload }

    describe 'klass' do
      context 'when passed a directory' do
        it { expect(described_class.klass(Pathname.new('.'))).to eq(Path) }
      end

      context 'when passed a file' do
        it { expect(described_class.klass(Pathname.new('Gemfile'))).to eq(Document) }
      end
    end
  end
end
