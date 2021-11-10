# frozen_string_literal: true

RSpec.shared_examples_for 'interpolate' do
  # let(:path) { Pathname.new(ENV['SPEC_DIR']).join('fixtures/context') }
  # let(:project) { Project.first }
  # let(:a_context) { Context.create(root: project, options: options) }
  describe 'cnfs_sub' do
    # let(:hash) { { 'domain' => 'context.com', 'test' => { 'this' => 'that'} } }

    it 'returns the correct interpolation' do
      # subject.config = hash
      # binding.pry
      expect(subject.cnfs_sub).to eq(result)
      # string = 'backend.${domain}'
      # expect(subject.config.cnfs_sub(references: [subject], value: hash)).to eq('backend.context.com')
    end

    # it 'returns the correct interpolation' do
    #   string = 'carry.${test.this}'
    #   # binding.pry
    #   expect(string.cnfs_sub(hash)).to eq('carry.that')
    # end
  end
end
