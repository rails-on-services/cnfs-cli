# frozen_string_literal: true

class Blueprint::Aws::Instance < Blueprint::Aws
  MODULES = %i[vpc ec2 acm alb cdn].freeze
  store :config, accessors: MODULES

  # NOTE: If the output is an array and the input expects and array then don't enclose in an array, ie []
  # NOTE: ${} notation is required to reference outputs from other modules
  def set_defaults
    if vpc
      vpc['source'] ||= 'terraform-aws-modules/vpc/aws'
      vpc['version'] ||= '~> 2.18.0'
    end
    if ec2
      ec2['source'] ||= "#{source}/ec2"
      ec2['subnet_ids'] ||= '${module.vpc.public_subnets}'
      ec2['vpc_id'] ||= '${module.vpc.vpc_id}'
    end
    if acm
      acm['source'] ||= 'terraform-aws-modules/acm/aws'
      acm['version'] ||= '~> 2.0.0'
      # acm['providers'] ||= { aws: 'aws.us-east-1' }
    end
    if alb
      alb['source'] ||= "#{source}/alb"
      alb['subnet_ids'] ||= '${module.vpc.public_subnets}'
      alb['vpc_id'] ||= '${module.vpc.vpc_id}'
      alb['acm_arn'] ||= '${module.acm.this_acm_certificate_arn}'
      alb['ec2_security_group_id'] ||= '${module.ec2.security_group_id}'
      alb['ec2_instance_id'] ||= '${module.ec2.this.id}'
      alb['route53_zone_id'] ||= acm['zone_id']
    end
    if cdn
      cdn['source'] ||= "#{source}/cdn"
      cdn['acm_arn'] ||= '${module.acm.this_acm_certificate_arn}'
      cdn['route53_zone_id'] ||= acm['zone_id']
    end
  end

  # ALB requires ACM, VPC and EC2
  # EC2 requires VPC

  # TODO: aws_ should be aws/ and in the parent model
  # instance should be demodulize.underscore and in parent
  def template
    'aws_instance'
  end

  def modules
    self.class::MODULES
  end

  # should be in base class
  def comma
    if @comma.nil?
      @comma = ','
    else
      @comma
    end
  end

  # def write
  #   File.open(Request.new(base: Context.first).write_path(:infra).join('main.tf.json'), 'w') { |f| f.write(erb) }
  # end

  # def erb
  #   ERB.new(erbs, trim_mode: '-').result(binding)
  # end

  # # TODO:
  # def erbs
  #   # ERB.new(IO.read(Cnfs.gem_root.join('app/models/fart.erb')), trim_mode: '-').result(binding)
  #   '<% MODULES.each do |key| -%>
  #     <%= { module: { key => { source: "./modules/#{key}", version: version }.merge(send(key)) } }.to_json %>
  #   <% end %>'
  # end
end
