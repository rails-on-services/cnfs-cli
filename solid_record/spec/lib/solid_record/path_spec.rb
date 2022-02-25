# frozen_string_literal: true

require_relative 'file_system_element_spec'

module SolidRecord
  RSpec.describe Path do
    before { DataStore.reload }

    context 'when infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:path) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-array') }
        let(:tempdir) { Pathname.new(Dir.mktmpdir) }

        let(:doc) do
          FileUtils.cp_r(path, tempdir)
          t_path = tempdir.join(path.basename)
          Element.create_from_path(t_path)
        end

        let(:host1) { Host.find_by(host: 's-test-1') }
        let(:host2) { Host.find_by(host: 's-test-2') }
        let(:group1) { Group.find_by(name: 'asc') }

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

        it_behaves_like 'FileSystemElement'

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(13)
          expect(Service.count).to eq(1)
        end

        context 'when destroy' do
          it {
            expect do
              host1.destroy
              SolidRecord.flush_cache
            end .to change(Document, :count).by(-1)
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
