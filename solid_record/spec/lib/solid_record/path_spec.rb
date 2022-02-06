# frozen_string_literal: true

# path: 'spec/dummay/data'
# layout:
# backend/development
# backend/production/cluster
# frontend/cluster
#
# 1. Single class at all levels of hierarchy (i.e. self referencing)
#    Required models: Segment
#    map: { '.' => 'segments' }
#
# 2. Consistent map of hierarchy paths to classes
#    Required models Stack, Environment, Target
#    map: { '.' => 'stacks', 'stacks' => 'environments', 'stacks/environments' => 'targets' }
#    map: 'stacks/environments/targets'
#
#    map: 'stacks/backend' => environments'
#    map: 'stacks/frontend' => targets'
#
# 3. Each path within the hierarchy has it's own class hierarchy
#    Required models Stack, Environment, Target
#    map: { '.' => 'stacks', 'frontend' => 'target', 'backend' => 'environments', backend/production' => 'target' })
#
# 4. Default
#    Required models: path.basename.to_s.classify
#    map: {}
#
class Stack; end

class Environment; end

module Test
  class Stack; end
end

module SolidRecord
  RSpec.describe Path do
    subject(:data_path) { described_class.new }

    describe '#valid?' do
      context 'when path is set' do
        before { data_path.path = '.' }

        it { is_expected.to be_valid }
      end

      context 'when path is not set' do
        it { is_expected.not_to be_valid }
      end
    end

    describe '#load' do
      context 'when model is valid' do
        before do
          allow_any_instance_of(described_class).to receive(:load_path).and_return([]) # rubocop:disable RSpec/AnyInstance
          data_path.path = '.'
        end
        # let(:my_instance) { instance_double(described_class) }
        # allow(described_class).to receive(:new).and_return(my_instance)
        # allow(my_instance).to receive(:load_path).and_return([])
        # before { data_path.path = '.' } # ; data_path.load }

        it { expect(data_path.load).not_to be_nil }
      end

      context 'when model is invalid' do
        it { expect(data_path.load).to be_nil }
      end
    end

    describe '#model_class_type' do
      context "with path: '.' and path_map: 'stacks/environments'" do
        subject(:data_path) { described_class.new(path: '.', path_map: 'stacks/environments') }

        context "when childpath is 'backend'" do
          it { expect(data_path.model_class_type(Pathname.new('backend'))).to eq('Stack') }

          context "with namespace 'test'" do
            before { data_path.namespace = 'test' }

            it { expect(data_path.model_class_type(Pathname.new('backend'))).to eq('Test::Stack') }
          end
        end

        context "when childpath is 'backend/production'" do
          it { expect(data_path.model_class_type(Pathname.new('backend/production'))).to eq('Environment') }
        end

        context "when config.raise_on_error is true and childpath is 'backend/production/cluster'" do
          it do
            SolidRecord.config.raise_on_error = true
            expect do
              data_path.model_class_type(Pathname.new('backend/production/cluster'))
            end .to raise_error(PathError)
          end

          context 'when recurse is true' do
            before { data_path.recurse = 'true' }

            it { expect(data_path.model_class_type(Pathname.new('backend/production/cluster'))).to eq('Environment') }
          end
        end
      end
    end
  end
end
