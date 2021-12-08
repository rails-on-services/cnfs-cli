# frozen_string_literal: true

require 'json'
require 'active_record'
require_relative '../../spec_helper'
require_relative '../../../app/models/terraform/plan'
require_relative '../../../app/models/terraform/wrapper'

class Context < ActiveRecord::Base; end
class Provider < ActiveRecord::Base; end
class Provisioner < ActiveRecord::Base; end
class Resource < ActiveRecord::Base; end

require_relative '../../../app/models/terraform/provisioner'

module Proxmox
  class Provider < Provider
    def terraform_resources_map
      { proxmox_vm_qemu: 'Proxmox::Resource::Vm::Qemu' }
    end
  end

  class Resource < Resource
    class Vm
      class Qemu < Resource; end
    end
  end
end

class Plan < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  # Stub methods invoked by the concern on the including class
  class << self
    def table_mod(method) = nil

    # def store(column_name, **options) = nil
  end

  include Terraform::Plan
end

RSpec.describe 'Plan' do
  let(:path) { Pathname.new(Dir.pwd).join('spec/fixtures/proxmox') }
  let(:wrapper) { Terraform::Wrapper.new(path: path) }
  let(:subject) { Plan.create(name: 'test', owner: Context.create, creates: 'Proxmox::Resource::Vm::Qemu') }
  let(:provider) { Proxmox::Provider.create(name: 'proxmox') }

  before do
    # CnfsCli.run!(path: path, load_nodes: true) do
    #   _n = Node::Component.create(path: 'project.yml', owner_class: Project)
    # end
  end

  describe 'create_resources' do
    it 'generates the correct number of contexts and context_components' do
      # NOTE: This would be set by the provisioner
      subject.wrapper = wrapper
      # binding.pry
      subject.create_resources
    end

    xit 'generates the correct number of providers' do
      expect(a_context.providers.count).to eq(3)
    end
  end
end
