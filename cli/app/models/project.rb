# frozen_string_literal: true

class Project < Component
  # belongs_to :source_repository, class_name: 'Repository'
  store :config, accessors: %i[paths logging x_components], coder: YAML

  before_validation :set_defaults

  before_create :mod_x_components, unless: proc { skip_node_create } 

  def create_node
    binding.pry
    node = Node::Component.create(owner: self, skip_owner_create: true,
                  path: CnfsCli.config.root.join('project.yml'))
    p = create_parent(type: 'Node::SearchPath', parent: node, path: 'config', skip_owner_create: true)
    binding.pry

    # parent = create_parent(type: 'Node::Component', owner: self, skip_owner_create: true,
                  # path: CnfsCli.config.root.join('project.yml'))
    # parent.nodes << Node::SearchPath.create(parent: parent, path: 'config', skip_owner_create: true)
  end

  def mod_x_components
    self.x_components = x_components.each_with_object([]) do |comp, ary|
      defaults = comp_defaults[comp[:name]] || {}
      ary.append(defaults.merge(comp))
    end
  end

  # "black" "red" "green" "yellow" "blue" "purple" "magenta" "cyan" "white"
  def comp_defaults
    {
      'target' => { aliases: '-t', color: 'blue' },
      'environment' => { aliases: '-e', env: 'env', color: 'green' },
      'namespace' => { aliases: '-e', env: 'ns', color: 'yellow' },
      'stack' => { aliases: '-e', color: 'red' }
    }
  end

  # name: default aliases env color
  def set_defaults
    self.x_components ||= []
  end

  # Node SearchPath
  def search_path
    Pathname.new(parent.path).split[0].join('config')
  end

  def except_json
    super.append('c_name', 'type')
  end

  def root_tree
    puts "\n#{super.render}"
  end

  def command_options
    @command_options ||= x_components.each_with_object([]) do |opt, ary|
    # @command_options ||= CnfsCli.config.config.x_components.each_with_object([]) do |opt, ary|
      opt = opt.to_h.with_indifferent_access
      # opt = opt.with_indifferent_access
      ary.append({ name: opt[:name].to_sym,
                   desc: opt[:desc] || "Specify #{opt[:name]}",
                   aliases: opt[:aliases],
                   type: :string,
                   default: opt[:default]
      })
    end
  end

  def command_options_list
    @command_options_list ||= CnfsCli.config.config.x_components.map{ |comp| comp[:name].to_sym }
  end

  # TODO: See what to do about encrypt/decrypt per env/ns

  # Returns an encrypted string
  #
  # ==== Parameters
  # plaintext<String>:: the string to be encrypted
  # scope<String>:: the encryption key to be used: environment or namespace
  def encrypt(plaintext, scope)
    send(scope).encrypt(plaintext)
  end

  def decrypt(ciphertext)
    namespace.decrypt(ciphertext)
  rescue Lockbox::DecryptionError => _e
    environment.decrypt(ciphertext)
  end
end
