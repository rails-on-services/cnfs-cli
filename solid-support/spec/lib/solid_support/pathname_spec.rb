# frozen_string_literal: true

# rubocop:disable Lint/EmptyClass
class Stack
end
# rubocop:enable Lint/EmptyClass

module SolidSupport
  RSpec.describe 'Pathname' do
    let(:subject) { Pathname }

    describe 'last_element_match' do
      let(:path_map) { 'stacks/environments/targets' }

      it 'returns the correct element' do
        expect(subject.new('backend').last_element_match(path_map)).to eq('stacks')
      end

      it 'returns the correct element' do
        expect(subject.new('backend/production').last_element_match(path_map)).to eq('environments')
      end

      it 'returns the correct element' do
        expect(subject.new('backend/production/cluster').last_element_match(path_map)).to eq('targets')
      end

      it 'returns nil when no element matches' do
        expect(subject.new('backend/production/cluster/default').last_element_match(path_map)).to be_nil
      end
    end

    describe 'inflector' do
      it 'inflectors return the proper response when file name is singular' do
        expect(subject.new('test.yml').singular?).to be_truthy
        expect(subject.new('test.yml').plural?).to be_falsey
      end

      it 'inflectors return the proper response when file name is plural' do
        expect(subject.new('tests.yml').singular?).to be_falsey
        expect(subject.new('tests.yml').plural?).to be_truthy
      end
    end

    describe 'safe_constantize' do
      let(:subject) { Pathname.new('stacks') }

      it 'returns the correct class' do
        expect(subject.name).to eq('stacks')
        expect(subject.classify).to eq('Stack')
        expect(subject.safe_constantize).to eq(::Stack)
      end
    end
  end
end
