# frozen_string_literal: true

class Runtime::Skaffold < Runtime
  def labels(base_labels, space_count)
    space_count ||= 12
    base_labels.select { |k, v| v }.map { |key, value| "#{label_base}/#{key.to_s.gsub('_', '-')}: #{value}" }.join("\n#{' ' * space_count}")
  end

  # This is the method ps command will call
  def services(format: '{{.Names}}', status: :running, **filters)
  end

  def exec(service_name, command)
    kubectl("exec -it #{service_pod(service_name)} -c #{service_name} #{command}", true)
  end

  # def generator_class; 'KubernetesGenerator' end
  def deploy_type; :kubernetes end

  private

  # def label_base; 'cnfs.io' end
  def label_base; 'app.kubernetes.io' end

  def service_pod(service_name); pod(name: service_name) end # , component: :server) end

  def pod(labels = {}); get_pods(labels, true) unless controller.options.noop end

  def pods(labels = {}); get_pods(labels) unless controller.options.noop end

  def get_pods(labels = {}, return_one = false)
    cmd = "get pod -l #{labels.map{ |k, v| "#{label_base}/#{k}=#{v}" }.join(',')} -o yaml"
    result = svpr(cmd)
    return result.first if return_one
    result
  end

  def svpr(cmd)
    kubectl_capture(cmd)
    if exit_code.positive?
      STDOUT.puts(stderr)
      Kernel.exit(1)
    end
    # TODO: Does this effectively handle > 1 pod running
    YAML.safe_load(stdout)['items'].map { |i| i['metadata']['name'] } unless options.n
  end

  # Supporting methods (2)
  def kubectl(cmd, never_capture = false)
    raise StandardError.new("kubeconfig not found at #{kubeconfig}") unless File.exist?(kubeconfig)
    system_cmd("kubectl -n #{namespace} #{cmd}", kube_env, never_capture)
  end

  def kubectl_capture(cmd)
    raise StandardError.new("kubeconfig not found at #{kubeconfig}") unless File.exist?(kubeconfig)
    capture_cmd("kubectl -n #{namespace} #{cmd}")
  end

  def kube_env; @kube_env ||= { 'KUBECONFIG' => kubeconfig, 'TILLER_NAMESPACE' => namespace } end

  def kubeconfig; @kubeconfig ||= "#{Dir.home}/.kube/config" end

  def namespace; @namespace ||= "#{application.current_feature_set}-#{Stack.config.name}" end
end
