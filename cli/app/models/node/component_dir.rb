# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :load_path, if: proc { Node.source.eql?(:node) }

  delegate :owner, to: :parent

  def config_file
    return rootpath.join('____not_found') unless owner.type
    rootpath.join("#{owner.type.underscore}.yml")
  end

  # Iterate over files and directories
  # rubocop:disable Metrics/AbcSize
  def load_path
    # Should this be a node?
    binding.pry if owner.nil?
    config_yaml = config_file.exist? ? (YAML.load_file(config_file) || {}) : {}
    owner.update(sub_config: config_yaml)
    # TODO: Each component other than nil type should have a loader instance
    # No. The loaders should be in Cnfs so they can be iterated over on reload7
    if owner.type&.eql?('Repository')
      Cnfs.add_loader(name: owner.name, path: rootpath)
    end

    # return if owner.type.eql?('Repository')
    # ComponentDirs contain assets (repositories.yml, repositories/). Create these first
    pathname.children.sort.select { |n| CnfsCli.asset_names.include?(base_name(n)) }.each do |path_name|
      if config_file.exist?
        next if owner.exclude.include?(base_name(path_name))
        next unless owner.include.include?(base_name(path_name))
      end

      node_type = path_name.directory? ? 'Node::AssetDir' : 'Node::AssetGroup'
      nodes.create(type: node_type, path: path_name.to_s)
    end
    check_components(pathname)
    # Create Components
    pathname.children.select(&:file?).reject { |n| CnfsCli.asset_names.include?(base_name(n)) }.each do |path_name|
      if config_file.exist?
        next if owner.exclude.include?(base_name(path_name))
        next unless owner.include.include?(base_name(path_name))
      end

      nodes.create(type: 'Node::Component', path: path_name.to_s)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # If a component dir exsists but not the file then create the file
  # rubocop:disable Style/MultilineBlockChain
  def check_components(path_name)
    path_name.children.reject do |n|
      CnfsCli.asset_names.include?(base_name(n))
    end.group_by { |n| base_name(n) }.each do |_name, ary|
      next if ary.size.eql?(2)

      FileUtils.touch("#{ary.first}.yml") if ary.first.directory?
      # FileUtils.mkdir(ary.first.to_s.delete_suffix('.yml')) if ary.first.file?
    end
  end
  # rubocop:enable Style/MultilineBlockChain

  # BEGIN: source asset

  after_destroy :destroy_yaml, if: proc { Node.source.eql?(:asset) }

  # Override Node#set_realpath to create the file first, otherwise super will fail due to path not existing
  def set_realpath
    return super if Node.source.eql?(:node) || persisted?

    # binding.pry
    path_n = Pathname.new(path)
    path_n.mkdir unless path_n.exist?
    super
  end

  def destroy_yaml
    rootpath.rmtree
  end
end
