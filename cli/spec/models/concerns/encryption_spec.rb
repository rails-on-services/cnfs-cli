# frozen_string_literal: true

RSpec.shared_examples_for 'encryption' do
  # let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/context') }
  # let(:project) { Project.first }
  # let(:a_context) { Context.create(root: project, options: options) }

  it 'deos' do
    expect(1).to eq(1)
  end
end
