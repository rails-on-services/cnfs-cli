# frozen_string_literal: true

class Builder::Terraform < Builder
  store :config, accessors: %i[custom_providers], coder: YAML

  def custom_providers
    super || {}
  end

  def prepare
    fetch_custom_providers
  end

  def required_tools
    %w[terraform]
  end

  # Commands called by ExecControllers
  def init
    rv('terraform init')
  end

  def plan
    rv('terraform plan')
  end

  def apply
    rv('terraform apply -auto-approve')
  end

  def destroy
    rv('terraform destroy -auto-approve')
  end

  # command support methods
  # TODO: this is specific to AWS
  def command_env
    # TODO: relook at how the aws creds and details are loaded and referenced
    { 'AWS_DEFAULT_REGION' => project.environment.provider.config['region'] }
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def fetch_custom_providers
    return if custom_providers.empty?

    if Cnfs.platform.nil?
      errors.add(:platform, 'not supported')
      return
    end
    require 'tty-file'
    require 'tty-spinner'


    Dir.chdir(path) do
      system_cmd('rm -rf .terraform/modules/') if options.clean
      spinner = TTY::Spinner.new("[:spinner] Downloading modules ...", format: :pulse_2)
      custom_providers.each do |provider|
        name = provider['name']
        url = provider['url']

        url = url.gsub('{platform}', Cnfs.platform)
        file = url.split(%r{/}).last
        if File.exist?(file) && !options.clean
          puts "Terraform provider #{file} exists locally. To overwrite run command with --clean flag."
          next
        end

        spinner.run { |spinner| TTY::File.download_file(url) }
      end
    end
  end

  def fetch_data_repo
    STDOUT.puts "Fetching data source v#{data.config.data_version}..."
    File.open('data.tar.gz', 'wb') do |fo|
      fo.write open("https://github.com/#{data.config.data_repo}/archive/#{data.config.data_version}.tar.gz",
                    'Authorization' => "token #{data.config.github_token}",
                    'Accept' => 'application/vnd.github.v4.raw').read
    end
    `tar xzf "data.tar.gz"`
  end
  # rubocop:enable Metrics/AbcSize
end
