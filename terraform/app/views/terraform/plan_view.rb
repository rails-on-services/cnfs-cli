# frozen_string_literal: true

class Terraform::PlanView < OneStack::ApplicationView
  def modify
    # ask_attr(:modules)

    # ec2_instance:
    #   source: terraform-aws-modules/ec2-instance/aws
    #   version: ~> 3.0
    #   name: single-instance

    #   # ami: ami-0a2bd6411b7d7da76 # amd64
    #   ami: ami-089c7bdc7cdb50a72 # arm64
    #   instance_type: t4g.micro
    #   key_name: rjayroach
    #   vpc_security_group_ids:
    #     - module.vpc.default_security_group_id
    #   subnet_id: module.vpc.public_subnets[0]
    #   tags:
    #     Terraform: "true"
    #     Environment: dev
    # provider = 
    instance_types = Aws::Resource::EC2.new(provider: Provider.first).instance_types(:t3)
    mod = collect do
      key(:mod_name).ask('name:', required: true, default: 'ec2_instance')
      key(:source).ask('source:', required: true, default: 'terraform-aws-modules/ec2-instance/aws')
      key(:version).ask('version:', required: true, default: '~> 3.0')
      key(:name).ask('name:', required: true, default: 'single-instance')
      key(:ami).ask('ami:', required: true, default: 'ami-089c7bdc7cdb50a72')
      key(:instance_type).enum_select_val(:region, choices: instance_types)
      key(:vpc_security_group_ids).values do
        key(:name).ask('name:', default: 'module.vpc.default_security_group_id')
      end
      key(:subnet_id).ask(:subnet_id, default: 'module.vpc.public_subnets[0]')
      # binding.pry
      # key(:instance_type)
    end
    name = mod.delete(:mod_name)
    model.modules[name] = mod

    # res2 = collect do
    #   key(:modules).values do
    #   #   # key(:ec2_instance).values do
    #   #   # end
    #   end
    # end
    # binding.pry
  end
end
