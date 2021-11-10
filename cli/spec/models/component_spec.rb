# frozen_string_literal: true

require "#{ENV['SPEC_DIR']}/models/concerns/encryption_spec.rb"
require "#{ENV['SPEC_DIR']}/models/concerns/interpolate_spec.rb"

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Component' do
  let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/context') }
  let(:project) { Project.first }
  # let(:a_context) { Context.create(root: project, options: options) }

  before do
    CnfsCli.run!(path: path, load_nodes: true) do
      _n = Node::Component.create(path: 'project.yml', owner_class: Project)
    end
  end

  describe 'interpolation' do
    let(:options) { { stack: :backend, environment: :production, target: :lambda } }

    describe 'does the correct interpolation for production' do
      let(:subject) { Component.find_by(name: :production) }
      let(:result) do
        { 'config' => { 'domain' => 'production-backend.cnfs.io' }, 'default' => 'lambda',
          'child_name' => 'target', 'name' => 'context_spec' }
      end
      # it_behaves_like 'encryption'
      it_behaves_like 'interpolate'
    end

    describe 'does the correct interpolation for lambda' do
      let(:subject) { Component.find_by(name: :lambda) }
      let(:result) do
        { 'config' => { 'host' => 'lambda.production-backend.cnfs.io' }, 'child_name' => 'target',
          'default' => 'lambda', 'name' => 'context_spec' }
      end
      # it_behaves_like 'encryption'
      it_behaves_like 'interpolate'
    end
  end
end
# rubocop:enable Metrics/BlockLength
