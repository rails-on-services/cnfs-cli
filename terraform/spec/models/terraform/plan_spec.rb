# frozen_string_literal: true

require_relative '../../spec_helper'

# module Proxmox
#   class Provider < Provider
#     def terraform_resources_map
#       { proxmox_vm_qemu: 'Proxmox::Resource::Vm::Qemu' }
#     end
#   end
# 
#   class Resource < Resource
#     class Vm
#       class Qemu < Resource; end
#     end
#   end
# end


RSpec.describe 'Plan' do
  let(:source_path) { SPEC_DIR.join('fixtures/segments') }
  let(:target_path) { SPEC_DIR.join('../../spec/segments') }
  let(:root) { SegmentRoot.first }
  let(:a_context) { Context.create(root: root, options: options) }

  let(:subject) { Plan.create(name: 'test', owner: Context.create, creates: 'Proxmox::Resource::Vm::Qemu') }
  let(:provider) { Proxmox::Provider.create(name: 'proxmox') }

  before do
    binding.pry
    setup_project(segment: :plan)
  end

  # after do
  #   target_path.rmtree if target_path.basename.to_s.eql?('segments')
  # end

  describe 'create_resources' do
    it 'generates the correct number of contexts and context_components' do
      binding.pry
      # binding.pry
      # subject.create_resources
    end

    xit 'generates the correct number of providers' do
      expect(a_context.providers.count).to eq(3)
    end
  end
end
