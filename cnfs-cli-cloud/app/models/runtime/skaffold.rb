# frozen_string_literal: true

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

  def requested_context; target.provider.kubectl_context(target) end

  def current_context
    run("config current-context").run!
    response.results.shift.chomp
  end

  def run(cmd, pty: false); response.add(env: kube_env, exec: kubectl(cmd), pty: pty) end

  def attach
    # binding.pry
    # get_vs(name: :ingress)
    service = request.last_service_name
    response.add(env: kube_env, exec: kubectl("exec -it #{service_pod(service)} -c #{service} bash"), pty: true)
  end

  def build # (services)
    # generate_config if stale_config
    request.services.each do |service|
      # service_file = "#{target_wr}/#{service}.yml"
      response.add(exec: skaffold("build -f #{service.name}.yml"), env: skaffold_env, dir: target.write_dir)
    end
    response

    # services.each do |service|
    #   next true unless platform.components.keys.include?(service.to_sym)

    #   service_file = "#{platform_root}/#{service}.yml"
    #   Dir.chdir(platform_root) do
    #     # TODO: next unless check and gem_version_check
    #     run_cmd = 'build'
    #     skaffold("#{run_cmd} -f #{File.basename(service_file)}")
    #     errors.add(:skaffold, stderr) if exit_code.positive?
    #   end
    # end
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
    binding.pry
    # update_helm_repo
    response
  end

  def update_helm_repo
    response.add(exec: 'helm repo add ros https://rails-on-services.github.io/helm-charts')
    response.add(exec: 'helm repo update')
    response.run!
  end

  def deploy_services
    env_file = "#{target.write_path(:deployment)}/application.env"
    sync_secret(env_file) if File.exists?(env_file)

    target.services.each do |service|
      # if service.name.eql?('kafka-connect')
      #   deploy_gcp_bigquery_secret unless application.components.services.components[:'kafka-connect']&.config&.gcp_service_account_key.nil?
      # end
      if service.name.eql?('ingress')
        next true unless options.n || virtual_service(name: :ingress).empty? || options.force
      else
        next if pod(name: service) unless @force_infra_deploy
      end
      env_file = "#{target.write_path(:deployment)}/#{service.name}.env"
      sync_secret(env_file) if File.exist?(env_file)
      service_file = "#{service}.yml"
      Dir.chdir(target.write_path(:deployment)) do
        base_cmd = options.build ? 'run' : 'deploy'
        force = @force_infra_deploy ? '--force=true' : ''
        skaffold("#{base_cmd} #{force} -f #{service_file}")
        # errors.add("skaffold_#{base_cmd}", stderr) if exit_code.positive?
      end
    end
  end

  def sync_secret(file)
    name = File.basename(file, '.env')
    return if local_secrets_content(file) == k8s_secrets_content(name)

    response.output.puts "NOTICE: Updating cluster with new contents for secret #{name}"
    response.add(exec: kubectl("delete secret #{name}")) # if kubectl("get secret #{name}")
    response.add(exec: kubectl("create secret generic #{name} --from-env-file #{file}"))
    response.run!
    # errors.add(:create_secret, stderr) if exit_code.positive?
  end

  def local_secrets_content(file)
    File.read(file).split("\n").each_with_object({}) { |a, h| b = a.split('='); h[b[0]] = b[1] || '' }
  end

  def k8s_secrets_content(type = 'platform')
    require 'base64'
    # TODO: Capture output using response command
    res = kubectl("get secret #{type} -o yaml")
    return {} if exit_code.positive? || options.n
    yml = YAML.load(stdout)
    yml['data'].each_with_object({}) { |a, h| h[a[0]] = Base64.decode64(a[1]) }
  end

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
  def labels(base_labels, space_count)
    space_count ||= 12
    base_labels.select { |k, v| v }.map { |key, value| "#{label_base}/#{key.to_s.gsub('_', '-')}: #{value}" }.join("\n#{' ' * space_count}")
  end

  # This is the method ps command will call
  def services(format: '{{.Names}}', status: :running, **filters)
  end

  # TODO: status is ignored for now
  def service_names(status: :running)
    services = query_cluster(:pods, component: :server)
    services.map{|m| m.split('-')[0] }.uniq
  end

  # TODO: replace with self.class.type
  def deploy_type; :kubernetes end

  private

  def virtual_service(labels = {}, return_one = false)
    result = query_cluster(:virtualservice, labels)
    return_one ? result.first : result
  end

  def query_cluster(asset_type, labels = {})
    label_string = labels.map{ |k, v| "app.kubernetes.io/#{k}=#{v}" }.join(',')
    cmd = kubectl("get #{asset_type} -l #{label_string} -o yaml")
    out, err = response.run(cmd)
    return [] unless (result = YAML.safe_load(out))

    result['items'].map { |i| i['metadata']['name'] }
  end

  # def skaffold(cmd, envs = {})
  #   puts "run skaffold with environment: #{skaffold_env.merge(envs)}" if options.v
  #   system_cmd("skaffold -n #{namespace} #{cmd}", skaffold_env.merge(envs))
  # end

  def skaffold(command) #, service_name = nil)
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
  def registry_secret_name; "registry-#{target.application.image_registry}" end

  def kubectl(command, service_name = nil)
    cmd = ['kubectl']
    cmd.append('-n', namespace) if namespace
    # cmd.append(service_names.include?(service_name) ? 'exec' : 'run --rm').append(service_name) if service_name
    cmd.append(command)
    cmd.join(' ')
  end

  def kube_env; @kube_env ||= { 'KUBECONFIG' => kubeconfig, 'TILLER_NAMESPACE' => namespace } end

  def check; File.file?(kubeconfig) end

  def kubeconfig; @kubeconfig ||= "#{Dir.home}/.kube/config" end

  # def show_command_output; request.options.verbose || request.options.debug end

  def namespace; @namespace ||= [request.args.namespace_name, request.args.application_name].compact.join('-') end

  def label_base; 'app.kubernetes.io' end # 'cnfs.io'
end
