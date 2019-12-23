# frozen_string_literal: true

class Runtime::Terraform < Runtime
  # TODO: Maybe custom_providers should be part of the config
  def before_execute_on_target
    fetch_custom_providers # (infra.config.custom_tf_providers)
  end

  # TODO: this is specific to AWS
  def cmd_environment
    { 'AWS_DEFAULT_REGION' => target.provider.region }
  end

  def init; system_cmd('terraform init', cmd_environment) end
  def plan; system_cmd('terraform plan', cmd_environment) end

  def fetch_custom_providers(providers = {})
    return if providers.empty?

    if platform.nil?
      errors.add(:platform, 'not supported')
      exit
    end

    system_cmd('rm -rf .terraform/modules/') if options.clean

    providers.each do |k, v|
      url = v.config.url.gsub('{platform}', platform)
      f = url.split(/\//).last
      if File.exist?(f) and not options.clean
        controller.output.puts "Terraform provider #{f} exists locally." \
          " To overwrite run command with --clean flag."
        next
      end
      download_provider(f, url)
    end
  end

  def platform
    case RbConfig::CONFIG['host_os']
    when /linux/
      'linux'
    when /darwin/
      'darwin'
    end
  end

  def download_provider(f, url)
    bytes_total = nil
    STDOUT.puts "Downloading terraform provider #{f}..."
    open(url, "rb", "Accept" => "application/vnd.github.v4.raw",
        :content_length_proc => lambda{|content_length|
          bytes_total = content_length},
        :progress_proc => lambda{|bytes_transferred|
          if bytes_total
            print("\r#{bytes_transferred/1024/1024}MB/#{bytes_total/1024/1024}MB")
          else
            print("\r#{bytes_transferred/1024/1024}MB (total size unknown)")
          end
        }) do |page|
      File.open(f, "wb") do |file|
        while chunk = page.read(1024)
          file.write(chunk)
        end
        File.chmod(0755, f)
      end
    end
  end

  def fetch_data_repo
    STDOUT.puts "Fetching data source v#{data.config.data_version}..."
    File.open("data.tar.gz", 'wb') do |fo|
      fo.write open("https://github.com/#{data.config.data_repo}/archive/#{data.config.data_version}.tar.gz",
          "Authorization" => "token #{data.config.github_token}",
          "Accept" => "application/vnd.github.v4.raw").read
    end
    %x(tar xzf "data.tar.gz")
  end
end
