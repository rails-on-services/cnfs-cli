# frozen_string_literal: true

module SolidRecord
  RSpec.describe File do
    before { SolidRecord.setup }

    context 'when infra' do
      let(:doc) { SolidRecord.toggle_callbacks { File.create(source: file_path, namespace: :infra) } }

      let(:model) { Element.first.model }

      let(:association) { doc.segments.first }

      let(:model_destroy) do
        # binding.pry
        model.destroy
        Element.flagged_for(:destroy).each(&:destroy)
      end

      context 'with monolithic yaml' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_hash/groups.yml') }

        before { doc }

        describe '#flag' do
          it { expect { model_destroy }.to change { doc.reload.flags.size }.by(1) }
        end

        describe '#write' do
          it {
            expect do
              model_destroy
              doc.write
            end .to change { doc.read.size }.by(-1)
          }
        end
      end
    end
  end
end
