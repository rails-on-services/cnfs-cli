# frozen_string_literal: true

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


module Terraform
  RSpec.describe Plan do
    let(:segment_root) { OneStack::SegmentRoot.first }
    let(:context) { OneStack::Navigator.new.context }

    # let(:subject) { Plan.create(name: 'test', owner: Context.create, creates: 'Proxmox::Resource::Vm::Qemu') }
    # let(:provider) { Proxmox::Provider.create(name: 'proxmox') }

    before { OneStack::SpecHelper.setup_segment(self) }

    describe 'create_resources' do
      it 'generates the correct number of contexts and context_components' do
        # ab = described_class
        binding.pry
        # subject.create_resources
      end

      xit 'generates the correct number of providers' do
        expect(a_context.providers.count).to eq(3)
      end
    end
  end
end
