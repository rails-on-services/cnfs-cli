# frozen_string_literal: true

module SolidRecord
  RSpec.describe Association do
    before { DataStore.reload }

    context 'with infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:file) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml') }
        let(:doc) { Element.create_from_path(file) }

        let(:association) { described_class.last }
        let(:elements) { association.elements }
        let(:model) { elements.last.model }
        let(:model_update) { model.update(port: 422) }
        let(:model_destroy) do
          model.destroy
          SolidRecord.cache_destroy
        end

        before { doc }

        describe '#to_solid' do
          it { expect(doc.to_solid.count).to be(4) }

          context 'when model updated' do
            # it { expect { model_update }.to change { doc.to_solid(:update).count }.from(0).to(1) }
            it { expect { model_update }.to change { doc.reload.flags.size }.from(0).to(1) }
          end

          context 'when model destroyed' do
            it { expect { model_update }.to change { doc.reload.flags.size }.from(0).to(1) }
            # it { expect { model_destroy }.to change { doc.to_solid(:update).count }.from(0).to(1) }
            it { expect { model_destroy }.to change(Element, :count).by(-1) }
          end
        end

        describe '#to_solid_array' do
          it { expect(doc.to_solid_array.class).to eql(Array) }
        end

        describe '#to_solid_hash' do
          it { expect(doc.to_solid_hash.class).to eql(Hash) }
        end

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
        end

        context 'with Association Element type' do
          it { expect(Service.first.element.parent).to be_an_instance_of(described_class) }
        end
      end

      context 'with monolithic yaml array' do
        let(:file) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-array/groups.yml') }
        let(:doc) { Element.create_from_path(file) }

        before { doc }

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(13)
          expect(Service.count).to eq(1)
        end
      end

      context 'with hierarchial yaml' do
        let(:group_file) { SPEC_ROOT.join('spec/dummy/infra/data/file/groups/asc.yml') }
        let(:hosts_file) { SPEC_ROOT.join('spec/dummy/infra/data/file/groups/asc/hosts.yml') }

        let(:group_doc) { Element.create_from_path(group_file) }

        let(:hosts_doc) do
          SolidRecord.skip_solid_record_callbacks do
            Document.create(path: hosts_file, owner: Group.first)
            # Document.create(model_type: 'Host', path: hosts_file, owner: Group.first)
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
        end
      end
    end

    context 'when stack' do
      before(:context) { SpecHelper.before_context('stack') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        it { expect(true).to be_truthy }
      end
    end
  end
end
