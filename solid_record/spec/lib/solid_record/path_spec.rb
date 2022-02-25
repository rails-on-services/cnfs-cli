# frozen_string_literal: true

require_relative 'file_system_element_spec'

module SolidRecord
  RSpec.describe Path do
    before { DataStore.reload }

    context 'when infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:path) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash') }

        let(:doc) do
          SolidRecord.skip_solid_record_callbacks do
            described_class.create(path: path)
          end
        end

        before { doc }

        it_behaves_like 'FileSystemElement'

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(11)
          expect(Service.count).to eq(1)
        end
      end
    end
  end
end
