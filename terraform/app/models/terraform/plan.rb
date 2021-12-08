# frozen_string_literal: true

require 'uri'

module Terraform
  module Plan
    extend ActiveSupport::Concern

    included do
      attr_accessor :wrapper
      table_mod :terraform_add_columns

      store :modules, coder: YAML
      store :variables, coder: YAML
      store :outputs, coder: YAML
      store :config, accessors: %i[creates]

      # store :terraform, coder: YAML
      # store :providers, coder: YAML
      # serialize :tf_modules, Array

      # validate :tf_modules_are_urls
    end

    # invoked by an instance of Terraform::Provisioner
    # NOTE: self is the specific plan which tells exactly what it's looking for
    def create_resources
      # RubyTerraform.state_list(chdir: path.parent.to_s)
      # RubyTerraform.state_show(chdir: path.parent.to_s, address: item)

      res = wrapper.resources_where(name: 'gm_dev', type: 'proxmox_vm_qemu', mode: 'managed')
      binding.pry

      # TODO: filter the tfstate based on what the plan is expecting
      terraform_resources.each do |resource_json|
        type = resource_json[:type].to_sym
        unless (klass = terraform_resource_to_class(type.to_s).constantize)
          Cnfs.logger.warn "Not found #{type}"
          next
        end

        binding.pry

        resource_json[:instances].each do |json|
          attrs = json[:attributes]
          obj_attrs = attrs.slice(*klass.stored_attributes[:config])
          # TODO: attrs are abstracted from tfstate based on the class
          # One way is a method on the resource #from_tfstate that takes the attrs and returns a slice
          # OR it directly creates the record and returns it
          obj = klass.new(obj_attrs, name: attrs[:bucket], owner: context.component)
          binding.pry
        end
      end
    end


    def terraform_resources() = tfstate[:resources] || []

    # 'aws_s3_bucket' => 'Aws::Resource::S3::Bucket'
    def terraform_resource_to_class(tf_type)
      provider, *type = tf_type.split('_')
      [provider, 'resource', *type].join('/').classify
    end

    def obj_vals(context)
      # Here loop over the resources created and create yaml files for those that have runtimes, e.g. EC2 instance
      hash = { owner: context.component } # , public_ip: output[:ec2_instance_public_ip]['value'] }

      # provider =  context.root.providers.find_by(name: self.context_plans.first.provider.name)
      runtime =  context.root.runtimes.find_by(name: :compose)

      # hash.merge!(provider: provider, provider_name: provider.name, runtime: runtime, runtime_name: runtime.name)
      hash.merge!(runtime: runtime, runtime_name: runtime.name)

      ic = Aws::Resource::EC2::Instance.new(hash)
    end

    def tf_modules_are_urls
      return unless Node.source.eql?(:asset)

      tf_modules.each do |mod|
        unless mod.is_a?(Hash)
          errors.add(:tf_modules, 'must be a Hash')
          next
        end
        next if mod.keys.include?('source')

        errors.add(:tf_modules, 'Must have a value for source or url') unless (url = mod['url'])
        errors.add(:tf_modules, url) unless valid_url?(url)
      end
    end

    def valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && !uri.host.nil?
    rescue URI::InvalidURIError
      false
    end

    def x_download
      # dependencies.each do |dependency|
      # dep = dependency[:url].cnfs_sub
      # Pathname.new('.terraform/modules').rmtree if options.clean
      url = tf_modules.last
      # g = git_clone(url)
      download(url, '/tmp')
      # binding.pry
      # path = '.terraform/modules'
    end

    class_methods do
      def terraform_add_columns(t)
        # t.string :terraform
        # t.string :providers
        t.string :variables
        t.string :modules
        t.string :outputs
      end
    end
  end
end
