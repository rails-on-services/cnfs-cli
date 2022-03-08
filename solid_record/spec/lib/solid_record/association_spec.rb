# frozen_string_literal: true

module SolidRecord
  RSpec.describe Association do
    before { DataStore.reset }

    context 'with infra' do
      before(:context) { SpecHelper.before_context('infra') }

      after(:context) { SpecHelper.after_context }

      context 'with monolithic yaml' do
        let(:file) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-hash/groups.yml') }
        let(:doc) { LoadPath.load(path: file) }

        let(:association) { described_class.last }
        let(:elements) { association.elements }
        let(:model) { elements.last.model }
        let(:model_update) { model.update(port: 422) }
        let(:model_destroy) do
          model.destroy
          ModelElement.flagged_for(:destroy).each(&:destroy)
        end

        before { doc }

        describe '#to_solid' do
          it { expect(doc.to_solid.count).to be(4) }

          context 'when model updated' do
            it { expect { model_update }.to change { doc.reload.flags.size }.from(0).to(1) }
            it { expect { model_update }.to change { doc.reload.flags.to_a.include?(:update) }.from(false).to(true) }
          end

          context 'when model destroyed' do
            it { expect { model_destroy }.to change { doc.reload.flags.size }.from(0).to(1) }
            it { expect { model_destroy }.to change { doc.reload.flags.to_a.include?(:update) }.from(false).to(true) }
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
          it { expect(Group.find_by(name: 'crack').hosts.count).to eq(6) }
        end

        context 'with Element count' do
          it { expect(Element.count).to eq(22) }
        end

        context 'with Association Element type' do
          it { expect(Service.first.element.parent).to be_an_instance_of(described_class) }
        end
      end

      context 'with monolithic yaml array' do
        let(:path) { SPEC_ROOT.join('spec/dummy/infra/data/monolith-array') }
        let(:doc) { LoadPath.load(path: path) }

        before { doc }

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(13)
          expect(Service.count).to eq(1)
        end
      end

      context 'with hierarchial yaml' do
        let(:group_file) { SPEC_ROOT.join('spec/dummy/infra/data/file/groups/crack.yml') }
        let(:hosts_file) { SPEC_ROOT.join('spec/dummy/infra/data/file/groups/crack/hosts.yml') }

        let(:group_doc) { LoadPath.load(path: group_file, model_type: 'Group') }
        let(:hosts_doc) { LoadPath.load(path: hosts_file, owner: -> { Group.first }) }

        context 'with Group and Host documents' do
          before do
            group_doc
            hosts_doc
          end

          describe '#model' do
            it { expect(group_doc.model_type).to eq('Group') }
            it { expect(hosts_doc.model_type).to eq('Host') }
            it { expect(Group.first).not_to be_nil }
            it { expect(Service.last.host.group).to eq(Group.first) }
          end
        end
      end
    end

    context 'when stack' do
      before(:context) { SpecHelper.before_context('stack') }

      after(:context) { SpecHelper.after_context }

      xit { expect(true).to be_truthy }
    end
  end
end
