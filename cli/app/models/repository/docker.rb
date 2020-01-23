# frozen_string_literal: true

class Repository::Docker < Repository
  store :config, accessors: %i[server username password email], coder: YAML

  def deploy_commands(runtime)
    # return if runtime.kubectl("get secret #{name}") unless runtime.options.force
    runtime.response.add(pty: true, exec: runtime.kubectl("create secret docker-registry #{name} #{docker_string}"))
  end

  def docker_string
    %w[server username password email].each_with_object([]) do |key, ary|
      ary.append("--docker-#{key}=#{send(key)}") if send(key)
    end.join(' ')
  end
end
