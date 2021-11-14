# frozen_string_literal: true

RSpec.describe 'Node' do
  describe 'prepare_fixtures' do
    describe 'type' do
      xit 'correctly identifies a single resource' do
        type = tree.nodes['spec/fixtures/config'].nodes['backend'].nodes['development'].nodes['resources'].nodes['cap4.yml'].type
      end
    end
  end
end
