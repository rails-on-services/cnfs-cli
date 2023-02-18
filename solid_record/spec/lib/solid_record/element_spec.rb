# frozen_string_literal: true

module SolidRecord
  RSpec.describe Element do
    before { SolidRecord.setup }

    context 'with infra' do
      let(:doc) { SolidRecord.toggle_callbacks { File.create(source: file_path, namespace: :infra) } }

      context 'with monolithic yaml' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_hash/groups.yml') }

        before { doc }

        it { expect(Infra::Host.last.element.root).not_to be_nil }
        describe '#root' do
        it { expect(Infra::Host.last.element.root).to eq(File.first) }
        end
      end
    end
  end
end
