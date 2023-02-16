# frozen_string_literal: true

module SolidRecord
  RSpec.describe Element do
    before { SolidRecord.setup }

    context 'with infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      let(:doc) { SolidRecord.toggle_callbacks { File.create(source: file_path) } }

      context 'with monolithic yaml' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_hash/groups.yml') }

        before { doc }

        it { expect(Host.last.element.document).not_to be_nil }
        describe '#document' do
        it { expect(Host.last.element.document).to eq(File.first) }
        end
      end
    end
  end
end
