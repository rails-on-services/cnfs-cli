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

module SolidRecord
  RSpec.describe 'DataPath' do
    let(:subject) { DataPath }

    before(:all) do
      DataStore.load
    end

    describe 'valid?' do
      it 'returns false if path is not set' do
        expect(subject.new).not_to be_valid
      end

      it 'returns true if path is set' do
        expect(subject.new(path: '.')).to be_valid
      end
    end

    describe 'load' do
      before do
        # allow_any_instance_of(DataPath).to receive(:create_document).and_return(nil)
        allow_any_instance_of(DataPath).to receive(:load_path).and_return([])
      end

      it 'returns nil when not valid' do
        expect(subject.new.load).to be_nil
      end

      it 'returns not nil when valid' do
        expect(subject.new(path: '.').load).not_to be_nil
      end
    end

    describe 'model_class_type' do
      let(:subject) { DataPath.new(path: '.', path_map: 'stacks/environments') }

      it 'returns the correct class' do
        expect(subject.model_class_type(Pathname.new('backend'))).to eq('Stack')
      end

      it 'returns the correct class' do
        expect(subject.model_class_type(Pathname.new('backend/production'))).to eq('Environment')
      end

      it 'raises an error if pathmap is invalid' do
        expect { subject.model_class_type(Pathname.new('backend/production/cluster')) }.to raise_error(ArgumentError)
      end

      it 'returns the correct class when recurse is true' do
        subject.recurse = 'true'
        expect(subject.model_class_type(Pathname.new('backend/production/cluster'))).to eq('Environment')
      end

      it 'returns the correct class when recurse is true' do
        subject.recurse = 'true'
        subject.path_map = 'stacks'
        expect(subject.model_class_type(Pathname.new('backend/production/cluster'))).to eq('Stack')
      end
    end
  end
end
