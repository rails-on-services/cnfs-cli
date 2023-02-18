# frozen_string_literal: true

module OneStack
  module Concerns; end
  class << self
    def table_name_prefix = 'one_stack_'

    def config = @config ||= set_config
    def application = @application ||= set_app

    def set_app
      app = ActiveSupport::OrderedOptions.new
      app.name = 'solid_record_spec'
      app
    end

    def set_config
      config = ActiveSupport::OrderedOptions.new
      config.asset_names = %w[operators providers provisioners resources repositories]
      config
    end

    def c = Component
    def co = Context
  end
end

path = Pathname.new(__dir__)

os = path.join('../../../../onestack/app/models/one_stack')
os.join('concerns').glob('*.rb').each { |p| require p }
%w[application_record provisioner].each do |f|
  require(os.join("#{f}.rb"))
end
os.glob('*.rb').each { |p| require p }

aws = path.join('../../../../aws/app/models/aws')
aws.glob('*.rb').each { |p| require p }
aws.join('resource').glob('*.rb').each { |p| require p }
aws.join('resource').glob('**/*.rb').each { |p| require p }
