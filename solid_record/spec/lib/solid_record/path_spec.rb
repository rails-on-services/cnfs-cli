# frozen_string_literal: true

module SolidRecord
  RSpec.describe Path do
    before { SolidRecord.setup }

    context 'when infra' do
      #a after(:context) { SpecHelper.after_context }
      let(:doc) { SolidRecord.toggle_callbacks { File.create(source: file_path, namespace: 'infra') } }

      context 'with monolithic yaml' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_hash/groups.yml') }

        let(:host1) { Infra::Host.find_by(host: 's-file-1') }
        let(:host2) { Infra::Host.find_by(host: 's-file-2') }
        let(:group1) { Infra::Group.find_by(name: 'crack') }

        let(:host1_update) do
          host1.update(port: 422)
          SolidRecord.flush_cache
        end
        let(:host2_update) do
          host1.update(port: 522)
          SolidRecord.flush_cache
        end
        let(:group1_update) do
          group1.update(auth_domain: 'test')
          SolidRecord.flush_cache
        end

        before { doc }

        # it_behaves_like 'FileSystemElement'

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          binding.pry
          expect(Infra::Group.count).to eq(4)
          expect(Infra::Host.count).to eq(11)
          expect(Infra::Service.count).to eq(1)
        end

        context 'when destroy' do
          it {
            expect do
              host1.destroy
              SolidRecord.flush_cache
            end .to change(File, :count).by(-1)
          }

          it {
            expect do
              host2.destroy
              SolidRecord.flush_cache
            end .to change(described_class, :count).by(-1)
          }
        end

        context 'when update' do
          it { expect { host1_update }.to change(Element, :count).by(0) }
          it { expect { group1_update }.to change(Element, :count).by(0) }
        end
      end
    end
  end
end
