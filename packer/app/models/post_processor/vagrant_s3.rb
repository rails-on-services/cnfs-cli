# frozen_string_literal: true

# See: https://github.com/lmars/packer-post-processor-vagrant-s3
class PostProcessor::VagrantS3 < PostProcessor
  # box_dir: The path to a directory in your bucket to store boxes in
  # box_name: This is what users of your box will set vm.config.box to in their Vagrantfil
  # version: The version of the box you are uploading. The box will be uploaded to a S3 directory path
  #   that includes the version number (e.g. vagrant/boxes/<version>)
  store :config, coder: YAML, accessors: %i[
    box_dir box_name bucket manifest region version
    access_key_id credentials profile secret_key session_token 
  ]

  # before_validation :set_defaults

  validates :version, presence: true
  validates :order, presence: true, uniqueness: true

  def set_defaults
    self.version ||= '0.0.1'
    self.box_dir ||= 'vagrant/boxes'
    self.box_name ||= build&.packer_name
    self.manifest ||= "#{box_name}.json"
    self.region ||= 'us-east-1'
  end

  def increment(type = :patch)
    self.version = bump(type)
  end

  def list_buckets
    @list_buckets ||= client.list_buckets.buckets.map(&:name)
  end

  private

  def bump(type = :patch)
    type = type.to_s.downcase
    return unless %w[major minor patch pre].include?(type)

    Dir.chdir(Cnfs.paths.tmp) do
      File.open('VERSION', 'w') { |f| f.write(version) }
      nv = Bump::Bump.next_version(type)
      FileUtils.rm('VERSION')
      nv
    end
  end

  def client
    @client ||= self.class.client(Provider.new(region: region))
  end

  # NOTE: Implementation of cnfs-cli-aws Provider::Aws API
  class Provider
    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def client_config(resource_type)
      config.slice(:access_key_id, :secret_access_key, :region).merge(config[resource_type] || {})
    end
  end

  # NOTE: Implementation of cnfs-cli-aws Resource::Aws API
  class << self
    def client(provider)
      require "aws-sdk-#{service_name}"
      klass = "Aws::#{service_class_name}::Client".safe_constantize
      raise Cnfs::Error, "AWS SDK client class not found for: #{service_name}" unless klass

      config = client_config(provider)
      klass.new(config)
    rescue LoadError => e
      raise Cnfs::Error, "AWS SDK not found for: #{service_name}"
    end

    def client_config(provider)
      provider.client_config(service_name)
    end

    def service_name
      :s3
    end

    def service_class_name
      :S3
    end
  end
end
