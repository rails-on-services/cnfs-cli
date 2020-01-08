# frozen_string_literal: true

class Runtime::Skaffold < Runtime
  # TODO: is there a detach keymap like with compose?
  # TODO: attach is actually shell (via exec)
  def attach
    # binding.pry
    # get_vs(name: :ingress)
    service = request.last_service_name
    response.add(env: kube_env, exec: kubectl("exec -it #{service_pod(service)} -c #{service} bash"), pty: true)
  end

  def labels(base_labels, space_count)
    space_count ||= 12
    base_labels.select { |k, v| v }.map { |key, value| "#{label_base}/#{key.to_s.gsub('_', '-')}: #{value}" }.join("\n#{' ' * space_count}")
  end

  # This is the method ps command will call
  def services(format: '{{.Names}}', status: :running, **filters)
  end

  def run(cmd); response.add(env: kube_env, exec: kubectl(cmd)) end

  # TODO: get the labels sorted out
  def exec(service_name, command, pty)
    pods = query_cluster(:pod, name: service_name, component: :server)
    return unless (pod = pods.first)

    response.add(exec: kubectl("exec -it #{pod} -c #{service_name} #{command}"), env: kube_env, pty: pty)
  end

  def deploy_type; :kubernetes end

  # Creates a new namespace in an existing cluster
  def create
    response.add(exec: "kubectl create ns #{namespace}", env: kube_env)
    response.add(exec: "kubectl label namespace #{namespace} istio-injection=enabled --overwrite", env: kube_env)
    # errors.add(:kubectl_label_namespace, stderr) if exit_code.positive? and stderr.index('AlreadyExists').nil?

    # deploy helm into namespace
    # TODO: Need to generate tiller-rbac
    response.add(exec: kubectl("apply -f #{target.write_path}/tiller-k8s-ns.yaml"), env: kube_env)
    response.add(exec: 'helm init --upgrade --wait --service-account tiller', env: kube_env)
  end

  # Deploy services based on tags
  def deploy
  end

  def destroy
    response.add(exec: "kubectl delete ns #{namespace}", env: kube_env)
  end


  private

  def virtual_service(labels = {}, return_one = false)
    result = query_cluster(:virtualservice, labels)
    return_one ? result.first : result
  end

  def query_cluster(asset_type, labels = {})
    label_string = labels.map{ |k, v| "app.kubernetes.io/#{k}=#{v}" }.join(',')
    cmd = kubectl("get #{asset_type} -l #{label_string} -o yaml")
    out, err = response.controller.command(response.controller.command_options).run(cmd, only_output_on_error: !request.options.debug)
    return [] unless (result = YAML.safe_load(out))

    result['items'].map { |i| i['metadata']['name'] }
  end

  def kubectl(command, service_name = nil)
    cmd = ['kubectl', '-n', namespace]
    # cmd.append(service_names.include?(service_name) ? 'exec' : 'run --rm').append(service_name) if service_name
    cmd.append(command)
    cmd.join(' ')
  end

  def kube_env; @kube_env ||= { 'KUBECONFIG' => kubeconfig, 'TILLER_NAMESPACE' => namespace } end

  def kubeconfig; @kubeconfig ||= "#{Dir.home}/.kube/config" end

  # def show_command_output; request.options.verbose || request.options.debug end

  def namespace; @namespace ||= request.args.namespace_name end

  def label_base; 'app.kubernetes.io' end # 'cnfs.io'
end
