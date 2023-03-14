# frozen_string_literal: true

class Docker::Registry < OneStack::Registry
  store :config, accessors: %i[server username password email], coder: YAML

  attr_encrypted :password

  def add_deploy_commands(runtime)
    # return if runtime.kubectl("get secret #{name}") unless runtime.options.force
    runtime.response.add(pty: true, exec: runtime.kubectl("create secret docker-registry #{name} #{docker_string}"))
  end

  def docker_string
    %w[server username password email].each_with_object([]) do |key, ary|
      ary.append("--docker-#{key}=#{send(key)}") if send(key)
    end.join(' ')
  end
end
