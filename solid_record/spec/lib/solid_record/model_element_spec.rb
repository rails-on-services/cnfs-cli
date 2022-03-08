# frozen_string_literal: true

module SolidRecord
  RSpec.describe ModelElement do
    before { DataStore.reset }

    context 'with infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:path) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml') }
        let(:doc) { LoadPath.load(path: path) }

        before { doc }

        it { expect(Host.last.element.document).not_to be_nil }
        it { expect(Host.last.element.document).to eq(Document.first) }
      end
    end
  end
end
