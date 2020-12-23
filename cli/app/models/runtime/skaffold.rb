# frozen_string_literal: true

require 'base64'

# rubocop:disable all
class Runtime::Skaffold < Runtime
  # TODO: is there a detach keymap like with compose?
  # TODO: attach is actually shell (via exec)

  def before_execute_on_target
    set_kubectl_context!
  end

  def set_kubectl_context!
    return if requested_context.eql?(current_context)

    run("config use-context #{requested_context}").run!
  end

  def requested_context
    target.provider.kubectl_context(target)
  end

  def current_context
    run('config current-context').run!
    response.results.shift.chomp
  end

  def run(cmd, pty: false)
    response.add(env: kube_env, exec: kubectl(cmd), pty: pty)
  end

  def attach
    # binding.pry
    # get_vs(name: :ingress)
    service = request.last_service_name
    response.add(env: kube_env, exec: kubectl("exec -it #{service_pod(service)} -c #{service} bash"), pty: true)
  end

  def build
    Dir.chdir(target.write_path) do
      request.services.each do |service|
        response.command.run("skaffold build -f #{service.name}.yml", env: skaffold_env)
      end
    end
    response
  end

  # Creates a new namespace in an existing cluster
  def create
    response.add(exec: "kubectl create ns #{namespace}", env: kube_env)
    response.add(exec: "kubectl label namespace #{namespace} istio-injection=enabled --overwrite", env: kube_env)
    # errors.add(:kubectl_label_namespace, stderr) if exit_code.positive? and stderr.index('AlreadyExists').nil?

    # deploy helm into namespace
    # TODO: Need to generate tiller-rbac
    response.add(exec: kubectl("apply -f #{target.write_path}/tiller-k8s-ns.yml"), env: kube_env)
    response.add(exec: 'helm init --upgrade --wait --service-account tiller', env: kube_env)
  end

  # Deploy services based on tags
  def deploy
    update_repositories
    sync_service_environment_files
    # deploy_services
    response
  end

  def update_repositories
    # NOTE: currently helm and dockerhub
    target.application.runtime_repositories.each do |repo|
      repo.add_deploy_commands(self)
      response.run!
    end
  end

  def sync_service_environment_files
    env_files.each do |file|
      name = File.basename(file, '.env')
      local = secrets_content(name, file, :local)
      remote = secrets_content(name, file, :cluster)
      sync_secret(name, file) unless local == remote
    end
  end

  def env_files
    Dir[target.write_path(:deployment).join('*.env')]
  end

  def secrets_content(name, file, type)
    unless type.eql?(:cluster)
      return File.read(file).split("\n").each_with_object({}) { |a, h| b = a.split('='); h[b[0]] = b[1] || '' }
    end

    cmd = kubectl("get secret #{name} -o yaml")
    result = response.command.run!(cmd, printer: null)
    return {} if result.failure?

    yml = YAML.safe_load(result.out)
    yml['data'].each_with_object({}) { |(key, value), hash| hash[key] = Base64.decode64(value) }
  end

  def sync_secret(_name, file)
    response.output.puts "NOTICE: Updating cluster with new contents from #{file}"
    if request.options.verbose
      response.output.puts local
      response.output.puts remote
    end
    # response.command.run!(kubectl("delete secret #{name}")) # if kubectl("get secret #{name}")
    # response.command.run!(kubectl("create secret generic #{name} --from-env-file #{file}"))
    # errors.add(:create_secret, stderr) if exit_code.positive?
  end

  def deploy_assets
    Dir.chdir(target.write_path(:deployment)) do
      target.deployment.assets.each do |asset|
        binding.pry
        # TODO: Code moved to Asset::Credential; Test this
        kube_cmd = asset.deploy_commands(self)
        response.command.run!(kube_cmd, env: kube_env)
      end
    end
  end

  def deploy_services
    Dir.chdir(target.write_path(:deployment)) do
      request.services.each do |service|
        # if service.name.eql?('kafka-connect')
        #   deploy_gcp_bigquery_secret unless application.components.services.components[:'kafka-connect']&.config&.gcp_service_account_key.nil?
        # end
        # if service.name.eql?('ingress')
        #   next true unless options.n || virtual_service(name: :ingress).empty? || options.force
        # else
        #   next if pod(name: service.name) unless @force_infra_deploy
        # end

        service_file = "#{service.name}.yml"
        base_cmd = request.options.build ? 'run' : 'deploy'
        force = request.options.force ? '--force=true' : ''
        cmd = skaffold("#{base_cmd} #{force} -f #{service_file}")
        res = response.command.run!(cmd, env: skaffold_env)
        binding.pry
        # errors.add("skaffold_#{base_cmd}", stderr) if exit_code.positive?
      end
    end
  end

  # skaffold delete and then skaffold deploy

  # kubectl rollout restart {type} {name}

  # -------------------------------------
  # END: New Stuff
  # -------------------------------------

  def destroy
    response.add(exec: "kubectl delete ns #{namespace}", env: kube_env)
  end

  # TODO: get the labels sorted out
  def exec(service_name, command, pty)
    pods = query_cluster(:pod, name: service_name, component: :server)
    return response unless (pod = pods.first)

    response.add(exec: kubectl("exec -it #{pod} -c #{service_name} #{command}"), env: kube_env, pty: pty)
  end

  # Utility Methods
  # This is the method ps command will call
  def services(format: '{{.Names}}', status: :running, **filters); end

  # TODO: status is ignored for now
  def service_names(status: :running)
    services = query_cluster(:pods, component: :server)
    services.map { |m| m.split('-')[0] }.uniq
  end

  # TODO: replace with self.class.type
  def deploy_type
    :kubernetes
  end

  def kubectl(command, _service_name = nil)
    cmd = ['kubectl']
    cmd.append('-n', namespace) if namespace
    # cmd.append(service_names.include?(service_name) ? 'exec' : 'run --rm').append(service_name) if service_name
    cmd.append(command)
    cmd.join(' ')
  end

  private

  def virtual_service(labels = {}, return_one = false)
    result = query_cluster(:virtualservice, labels)
    return_one ? result.first : result
  end

  def query_cluster(asset_type, labels = {})
    label_string = labels.map { |k, v| "app.kubernetes.io/#{k}=#{v}" }.join(',')
    cmd = kubectl("get #{asset_type} -l #{label_string} -o yaml")
    out, err = response.run(cmd)
    return [] unless (result = YAML.safe_load(out))

    result['items'].map { |i| i['metadata']['name'] }
  end

  # def skaffold(cmd, envs = {})
  #   puts "run skaffold with environment: #{skaffold_env.merge(envs)}" if options.v
  #   system_cmd("skaffold -n #{namespace} #{cmd}", skaffold_env.merge(envs))
  # end

  def skaffold(command) # , service_name = nil)
    cmd = ["skaffold -n #{namespace} #{command}"]
  end

  def skaffold_env
    @skaffold_env ||= {
      'SKAFFOLD_DEFAULT_REPO' => target.application.image_registry,
      'IMAGE_TAG' => target.application.image_tag(target)
    }.merge(kube_env)
  end

  # TODO: The service model has an image_registry value which if nil gets from the application
  # This method just creates a name of a secrets file in which to store the repo secret on k8s
  # def registry_secret_name; "registry-#{target.application.image_registry}" end

  def kube_env
    @kube_env ||= { 'KUBECONFIG' => kubeconfig, 'TILLER_NAMESPACE' => namespace }
  end

  def check
    File.file?(kubeconfig)
  end

  def kubeconfig
    @kubeconfig ||= "#{Dir.home}/.kube/config"
  end

  # def show_command_output; request.options.verbose || request.options.debug end

  def namespace
    @namespace ||= [request.args.namespace_name, request.args.application_name].compact.join('-')
  end

  # TODO: move to base runtime including label_base ?
  def labels(labels)
    super.transform_keys { |key| "#{label_base}/#{key}" }
  end

  # TODO: Get this from configuration files
  # 'cnfs.io' ?
  def label_base
    'app.kubernetes.io'
  end
end
# rubocop:enable all
