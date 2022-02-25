# frozen_string_literal: true

require_relative 'file_system_element_spec'

module SolidRecord
  RSpec.describe Document do
    before { DataStore.reload }

    context 'when infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      let(:tempdir) { Pathname.new(Dir.mktmpdir) }

      let(:doc) do
        FileUtils.cp_r(file.parent, tempdir)
        path = tempdir.join(file.parent.basename, file.basename)
        Element.create_from_path(path)
      end

      let(:model) { RootElement.first.model }
      let(:model_destroy) do
        model.destroy
        SolidRecord.cache_destroy
      end

      context 'with monolithic yaml' do
        let(:file) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml') }

        before { doc }

        after { tempdir.rmtree }

        it_behaves_like 'FileSystemElement'

        describe '#to_solid' do
          it { expect(doc.to_solid.keys).to eql(doc.read.keys) }

          context 'when element deleted' do
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
