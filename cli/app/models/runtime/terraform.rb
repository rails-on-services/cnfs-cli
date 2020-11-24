# frozen_string_literal: true

class Runtime::Terraform < Runtime
  store :config, accessors: %i[custom_providers], coder: YAML

  def custom_providers
    super || {}
  end

  def before_execute_on_target
    fetch_custom_providers
  end

  # TODO: this is specific to AWS
  def cmd_environment
    { 'AWS_DEFAULT_REGION' => context.target.provider.aws_region }
  end

  def init
    response.add(exec: 'terraform init', env: cmd_environment, pty: true)
  end

  def plan
    response.add(exec: 'terraform plan', env: cmd_environment, pty: true)
  end

  def apply
    response.add(exec: 'terraform apply', env: cmd_environment, pty: true)
  end

  def destroy
    response.add(exec: 'terraform destroy', env: cmd_environment, pty: true)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def fetch_custom_providers
    return if custom_providers.empty?

    if Cnfs.platform.nil?
      errors.add(:platform, 'not supported')
      exit
    end

    system_cmd('rm -rf .terraform/modules/') if context.options.clean

    Dir.chdir(context.write_path(:infra)) do
      custom_providers.each do |_name, url|
        url = url.gsub('{platform}', Cnfs.platform)
        f = url.split(%r{/}).last
        if File.exist?(f) && !context.options.clean
          context.output.puts "Terraform provider #{f} exists locally." \
            ' To overwrite run command with --clean flag.'
          next
        end
        download_provider(f, url)
      end
    end
  end

  # TODO: Use TTY::Progress here
  def download_provider(provider, url)
    bytes_total = nil
    STDOUT.puts "Downloading terraform provider #{provider}..."
    open(url, 'rb', 'Accept' => 'application/vnd.github.v4.raw',
                    :content_length_proc => lambda { |content_length|
                                              bytes_total = content_length
                                            },
                    :progress_proc => lambda { |bytes_transferred|
                                        if bytes_total
                                          print("\r#{bytes_transferred / 1024 / 1024}MB/#{bytes_total / 1024 / 1024}MB")
                                        else
                                          print("\r#{bytes_transferred / 1024 / 1024}MB (total size unknown)")
                                        end
                                      }) do |page|
      File.open(provider, 'wb') do |file|
        while (chunk = page.read(1024))
          file.write(chunk)
        end
        File.chmod(0o755, file)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

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
