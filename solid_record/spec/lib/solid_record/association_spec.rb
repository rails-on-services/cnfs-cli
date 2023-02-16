# frozen_string_literal: true

module SolidRecord
  RSpec.describe Association do
    before { SolidRecord.setup }

    context 'with infra' do
      before(:context) { SpecHelper.before_context(:infra) }

      after(:context) { SpecHelper.after_context }

      let(:doc) { SolidRecord.toggle_callbacks { File.create(source: file_path) } }

      context 'with monolithic yaml' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_hash/groups.yml') }

        let(:association) { described_class.last }
        let(:segments) { association.segments }
        let(:model) { segments.last.model }
        let(:model_update) { model.update(port: 422) }
        let(:model_destroy) do
          model.destroy
          Element.flagged_for(:destroy).each(&:destroy)
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
          it { expect(Element.count).to eq(16) }
        end

        context 'with Association Element type' do
          it { expect(Service.first.element.parent).to be_an_instance_of(described_class) }
        end
      end

      context 'with monolithic yaml array' do
        let(:file_path) { DUMMY_ROOT.join('infra/plural_array/groups.yml') }

        before { doc }

        it 'creates the correct number of Models' do # rubocop:disable RSpec/MultipleExpectations
          expect(Group.count).to eq(4)
          expect(Host.count).to eq(13)
          expect(Service.count).to eq(1)
        end
      end

      xcontext 'with hierarchial yaml' do
        let(:group_file) { DUMMY_ROOT.join('infra/plural_dir/groups/crack.yml') }
        let(:hosts_file) { DUMMY_ROOT.join('infra/plural_dir/groups/crack/hosts.yml') }

        let(:group_doc) { SolidRecord.toggle_callbacks { File.create(source: group_file, model_class_name: 'Group') } }
        let(:hosts_doc) { SolidRecord.toggle_callbacks { File.create(source: hosts_file, owner: Group.first) } }

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

    xcontext 'when stack' do
      before(:context) { SpecHelper.before_context('stack') }

      after(:context) { SpecHelper.after_context }

      xit { expect(true).to be_truthy }
    end
  end
end
