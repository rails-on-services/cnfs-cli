# frozen_string_literal: true

module SolidRecord
  RSpec.describe RootElement do
    before { DataStore.reload }

    context 'with infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml')) }

        let(:doc) { SolidRecord.skip_model_callbacks { YamlDocument.create(klass_type: 'Group', path: file) } }

        describe 'count' do
          it 'creates the correct number of Files' do
            expect(false).to be_falsey
            # expect(Host.last.element.root.document).to eq(Document.first)
          end
        end
      end
    end
  end
end
