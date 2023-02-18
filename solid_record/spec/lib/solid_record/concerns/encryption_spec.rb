# frozen_string_literal: true

module SolidRecord
  RSpec.shared_examples_for 'encrypted' do
    it 'decrypts all attrs' do
      rf = subject.class.new(subject.parent.yaml)
      rf.valid?
      expect(subject.as_json).to eq(rf.as_json)

      # TODO: When encrypted yaml remains unchnaged when saving back then enable this expectation
      # expect(subject.as_json_encrypted).to eq(rf.as_json_encrypted)

      describe 'encryption' do
        let(:options) { { stack: :backend, environment: :production, target: :lambda } }

        describe 'does the correct encryption for project' do
          let(:subject) { Project.first }
          # it_behaves_like 'encrypted'
        end

        describe 'does the correct encryption for lambda' do
          let(:subject) { Component.find_by(name: :lambda) }
          # it_behaves_like 'encrypted'
        end
      end
    end
  end
end
