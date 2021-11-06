# frozen_string_literal: true

class Project < Component
  # belongs_to :source_repository, class_name: 'Repository'
  # store :config, accessors: %i[paths logging x_components], coder: YAML

  def c_name
    'project'
  end

  def as_json
    super.merge('name' => name)
  end

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

  # Node SearchPath
  def search_path
    Pathname.new(parent.path).split[0].join('config')
  end

  # Display the project's components as a TreeView
  def root_tree
    puts "\n#{super.render}"
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
