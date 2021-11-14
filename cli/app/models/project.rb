# frozen_string_literal: true

class Project < Component
  attr_encrypted :happy
  # belongs_to :source_repository, class_name: 'Repository'
  store :config, accessors: %i[happy]

  def key
    @key ||= super || warn_key
  end

  def warn_key
    Cnfs.logger.error("No encryption key found. Run 'cnfs project generate_key'")
    nil
  end

  def c_name
    'project'
  end

  def as_json
    super.merge('name' => name)
  end

  # def create_node
  #   binding.pry
  #   node = Node::Component.create(owner: self, path: CnfsCli.config.root.join('project.yml'))
  #   p = create_parent(type: 'Node::SearchPath', parent: node, path: 'config')
  #   binding.pry
  #
  #   # parent = create_parent(type: 'Node::Component', owner: self,
  #                 # path: CnfsCli.config.root.join('project.yml'))
  #   # parent.nodes << Node::SearchPath.create(parent: parent, path: 'config')
  # end

  # called by Node::Component
  def dir_path
    'config'
    # Pathname.new(parent.path).split[0].join('config')
  end

  # Display the project's components as a TreeView
  def root_tree
    puts "\n#{super.render}"
  end
end
