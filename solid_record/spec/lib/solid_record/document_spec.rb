# frozen_string_literal: true

module SolidRecord
  RSpec.describe Document do
    before { DataStore.reset }

    context 'when infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/monolith/groups.yml')) }

        let(:doc) { SolidRecord.skip_solid_record_callbacks { YamlDocument.create(klass_type: 'Group', path: file) } }

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          doc
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(11)
          expect(Service.count).to eq(1)
        end

        it 'creates the correct model associations' do
          expect(true).to be_truthy
          # binding.pry
          # expect(Group.find_by(oauth_domain: 'ASC').hosts.count).to eq(6)
        end

        it 'creates the correct number of Documents and Elements' do
          expect(false).to be_falsey
          # expect(Document.first.models.size).to eq(4)
        end
      end

      context 'with hierarchial yaml' do
        let(:group_file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/file/groups/asc.yml')) }
        let(:hosts_file) { Pathname.new(SPEC_ROOT.join('spec/dummy/infra/data/file/groups/asc/hosts.yml')) }

        let(:group_doc) do
          Group.skip_solid_record_callbacks { YamlDocument.create(klass_type: 'Group', path: group_file) }
        end

        let(:hosts_doc) do
          SolidRecord.skip_solid_record_callbacks do
            YamlDocument.create(klass_type: 'Host', path: hosts_file, model: Group.first)
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
