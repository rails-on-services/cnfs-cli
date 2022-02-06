# frozen_string_literal: true

module SolidRecord
  RSpec.describe Document do
    before { DataStore.reload }

    context 'when infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml')) }

        let(:doc) do
          SolidRecord.skip_solid_record_callbacks do
            described_class.create(model_type: 'Group', path: file)
          end
        end

        before { doc }

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(11)
          expect(Service.count).to eq(1)
        end

        context 'when Group has_many Hosts' do
          it { expect(Group.find_by(name: 'asc').hosts.count).to eq(6) }
        end

        context 'with Element count' do
          it { expect(Element.count).to eq(22) }
          # it { binding.pry; expect(Element.count).to eq(22) }

          it {
            Element.last.model.update(port: 42)
            expect(true).to be_truthy
          }
        end

        context 'with Association Element type' do
          it { expect(Service.first.element.parent).to be_an_instance_of(Association) }
        end
      end

      context 'with monolithic yaml array' do
        let(:file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/monolith-array/groups.yml')) }

        let(:doc) do
          SolidRecord.skip_solid_record_callbacks do
            described_class.create(model_type: 'Group', path: file)
          end
        end

        before { doc }

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(11)
          expect(Service.count).to eq(1)
        end
      end

      context 'with hierarchial yaml' do
        let(:group_file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/file/groups/asc.yml')) }
        let(:hosts_file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/file/groups/asc/hosts.yml')) }

        let(:group_doc) do
          Group.skip_solid_record_callbacks { described_class.create(model_type: 'Group', path: group_file) }
        end

        let(:hosts_doc) do
          SolidRecord.skip_solid_record_callbacks do
            described_class.create(model_type: 'Host', path: hosts_file, model: Group.first)
          end
        end

        context 'with Group and Host documents' do
          before do
            group_doc
            hosts_doc
          end

          describe '#model' do
            it { expect(Service.last.host.group).to eq(Group.first) }
          end

          # describe 'Group.first#main' do
          #   it { expect(Group.first.main).to eq(main) }
          # end
        end
      end
    end

    context 'when stack' do
      before(:context) { SpecHelper.before_context('stack') }

      after(:context) { SpecHelper.after_context }

      # Pathname.new('.').glob('../core/app/models/*.rb').each { |path| require_relative path }

      context 'with monolithic yaml' do
        it { expect(true).to be_truthy }
      end
    end
  end
end
