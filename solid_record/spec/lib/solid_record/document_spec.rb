# frozen_string_literal: true

require_relative 'file_system_element_spec'

module SolidRecord
  RSpec.describe Document do
    before { DataStore.reset }

    context 'when infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      let(:doc) { LoadPath.load(path: file) }

      let(:model) { RootElement.first.model }

      let(:model_destroy) do
        model.destroy
        ModelElement.flagged_for(:destroy).each(&:destroy)
      end

      context 'with monolithic yaml' do
        let(:file) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml') }

        before { doc }

        it_behaves_like 'FileSystemElement'

        describe '#to_solid' do
          it { expect(doc.to_solid.keys).to eql(doc.read.keys) }

          context 'when element destroyed' do
            it { expect { model_destroy }.to change(RootElement, :count).by(-1) }
            it { expect { model_destroy }.to change { doc.elements.count }.by(-1) }
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
