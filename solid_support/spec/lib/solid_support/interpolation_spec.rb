# frozen_string_literal: true

module SolidSupport
  RSpec.shared_examples_for 'Interpolation' do
    let(:valid_path) { described_class.new(model_type: 'test', path: '.') }
    let(:invalid_path) { described_class.new(model_type: 'test', path: 'invalid_path') }
    let(:no_path) { described_class.new(model_type: 'test') }

    describe '#interpolation' do
      let(:options) { { stack: :backend, environment: :production, target: :lambda } }

      describe 'does the correct interpolation for production' do
        let(:subject) { Component.find_by(name: :production) }
        let(:result) do
          { 'config' => { 'domain' => 'production-backend.cnfs.io' }, 'default' => 'lambda',
            'segment' => 'target', 'name' => 'context_spec' }
        end
        # it_behaves_like 'interpolated'
      end

      describe 'does the correct interpolation for lambda' do
        let(:subject) { Component.find_by(name: :lambda) }
        let(:result) do
          { 'config' => { 'host' => 'lambda.production-backend.cnfs.io' }, 'segment' => 'target',
            'default' => 'lambda', 'name' => 'context_spec' }
        end
        # it_behaves_like 'interpolated'
      end
    end
  end
end
