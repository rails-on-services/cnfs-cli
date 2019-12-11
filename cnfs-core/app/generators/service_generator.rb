# frozen_string_literal: true

class ServiceGenerator < GeneratorBase
  def env
    template('env.erb', "#{@write_path}/#{service.name}.env") unless environment.empty?
  end

  def manifest
    # binding.pry
    template("service/#{service.name}/#{orchestrator}.yml.erb", "#{@write_path}/#{service.name}.yml")
  end

  private

  def environment
    service.environment.self || {}
  end

  def depends_on; %w[localstack] end

  def pull_policy; 'Always' end

  def mount; target.mount end

  delegate :name, to: :service
  delegate :orchestrator, :version, to: :target

  def expose_ports(port)
    port, proto = port.to_s.split('/')
    host_port = map_ports_to_host ? "#{port}:" : ''
    proto = proto ? "/#{proto}" : ''
    "\"#{host_port}#{port}#{proto}\""
  end

  def map_ports_to_host; false end

  def labels(space_count = nil)
    target.runtime.labels(base_labels, space_count)
  end

  # TODO: Are other labels needed at all?
  def base_labels
    %i[deployment application target layer service].each_with_object({}) do |type, hash|
      hash[type] = send(type).name
    end
  end

  def env_files(space_count = 6)
    @env_files ||= set_env_files.join("\n#{' ' * space_count}- ")
  end

  def set_env_files
    files = []
    files << "../../#{layer_type}/#{layer.name}/#{service.name}.env" if File.exist?("#{write_path}/#{service.name}.env")
    cpath = write_path.join('..')
    cxpath = Pathname.new('..')
    cpath.to_s.split('/').size.times do
      Dir["#{cpath}/*.env"].each do |file|
        # files << "#{cxpath}/#{File.basename(file)}"
        files << "../../#{layer_type}/#{File.basename(file)}"
      end
      cpath = cpath.join('..')
      cxpath = cxpath.join('..')
    end
    files
  end
end
