# frozen_string_literal: true

RSpec.describe 'Project' do
  before do
    ActiveRecord::Schema.define do |s|
      Project.create_table(s)
    end
  end

  describe 'prepare_fixtures' do
    it 'is great' do
      c = Project.create(hello: 'hi')
      expect(c.hello).to eq('hi')
    end
  end
end
