# frozen_string_literal: true

RSpec.describe 'Context' do
  before do
      path = Pathname.new(ENV['SPEC_DIR']).join('fixtures/simple')
      Dir.chdir(path) do
        CnfsCli.run!
        require 'cnfs/configuration'
        Cnfs::Configuration.initialize!
        # n = Node.create(path: 'project.yml', asset_type: 'project')
      end
    # ActiveRecord::Schema.define do |s|
    #   Context.create_table(s)
    #   Project.create_table(s)
    # end
  end

  describe 'prepare_fixtures' do
    it 'parses cli options' do
      options = Thor::CoreExt::HashWithIndifferentAccess.new(stack: 'backend', environment: 'development')
      p = Project.create(name: 'test')
      c = Context.create(options: options, root: p)
      # binding.pry
      expect(c.root.name).to eq('test')
    end
  end
end
