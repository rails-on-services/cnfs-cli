# frozen_string_literal: true

module SolidRecord
  RSpec.describe File do
    before { SolidRecord.setup }

    context 'when infra' do
      before(:context) { SpecHelper.before_context(:infra) }

      after(:context) { SpecHelper.after_context }

      let(:doc) { SolidRecord.toggle_callbacks { File.create(source: file_path) } }

      let(:model) { Element.first.model }

      let(:association) { doc.segments.first }

      let(:model_destroy) do
        model.destroy
        Element.flagged_for(:destroy).each(&:destroy)
      end

      context 'with monolithic yaml' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_hash/groups.yml') }

        before { doc }

        describe '#to_solid' do
          it { expect(doc.to_solid.keys).to eql(doc.read.keys) }

          context 'when element destroyed' do
            it { expect { model_destroy }.to change(Element, :count).by(-1) }
            it { expect { model_destroy }.to change { association.segments.count }.by(-1) }
            it { expect { model_destroy }.to change { doc.to_solid.keys.size }.by(-1) }
          end
        end

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
