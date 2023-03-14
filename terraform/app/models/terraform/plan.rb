# frozen_string_literal: true

module Terraform
  class Plan < OneStack::Plan
    store :modules, coder: YAML
    store :variables, coder: YAML
    store :outputs, coder: YAML
    store :config, accessors: %i[creates]

    # store :terraform, coder: YAML
    # store :providers, coder: YAML
    # serialize :tf_modules, Array

    # validate :tf_modules_are_urls
    after_deploy :create_resources

    after_undeploy :destroy_resources

    # TODO: This is all about reading a state file
    # Maybe is better to put these methods into the State class
    def destroy_resources(operator)
      # Cnfs.logger.warn 'after undeploy', name, operator
      iterate(operator.previous_state) do |model, attrs|
        # TODO: do a diff on operator.state.resources
        binding.pry
      end
    end

    # operator is an instance of Terraform::Provisioner
    def create_resources(operator)
      iterate(operator.state) do |model, attrs|
        obj = model.new(name: attrs[:tags][:Name], # , instance_id: attrs[:id],
                        # ami: attrs[:ami], public_ip: attrs[:public_ip], arn: attrs[:arn],
                        config: attrs,
                        provider: Provider.first, runtime: Runtime.first,
                        provider_name: Provider.first.name, runtime_name: Runtime.first.name,
                       )
        if obj.valid?
          obj.save
        else
          Cnfs.logger.warn(obj.errors)
        end
        # binding.pry
      end
    end

    def iterate(state)
      # Cnfs.logger.warn 'after', name, operator
      self.modules.keys.each do |key|
        next unless (plan_resources = state.resources.where(module: "module.#{key}")).any?

        resource_to_model_map.each do |resource_type, model_type|
          next unless (model = model_type.safe_constantize)

          next unless (resources = plan_resources.where(type: resource_type)).any?

          instances = resources.map(&:instances).flatten.map(&:attributes)
          instances.each do |attrs|
            yield model, attrs
          end
        end
      end
    end

    def resource_to_model_map
      { aws_instance: 'Aws::Resource::EC2::Instance' }
    end

    # 'aws_s3_bucket' => 'Aws::Resource::S3::Bucket'
    def resource_to_model(tf_type)
      provider, *type = tf_type.split('_')
      [provider, 'resource', *type].join('/').classify
    end

    # def obj_vals(context)
    #   # Here loop over the resources created and create yaml files for those that have runtimes, e.g. EC2 instance
    #   hash = { owner: context.component } # , public_ip: output[:ec2_instance_public_ip]['value'] }
    #
    #   # provider =  context.root.providers.find_by(name: self.context_plans.first.provider.name)
    #   runtime =  context.root.runtimes.find_by(name: :compose)
    #
    #   # hash.merge!(provider: provider, provider_name: provider.name, runtime: runtime, runtime_name: runtime.name)
    #   hash.merge!(runtime: runtime, runtime_name: runtime.name)
    #
    #   ic = Aws::Resource::EC2::Instance.new(hash)
    # end

    # TODO: These next two methods should be in a concern along w/ download
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
  end
end
