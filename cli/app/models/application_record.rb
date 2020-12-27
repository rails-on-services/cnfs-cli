# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_destroy :destroy_in_file
  after_save :save_in_file

  def edit
    view_class.new(model: self).edit
    update(attributes)
    self
  end

  def view_class
    self.class::View
  end

  def destroy_in_file
    content = YAML.load_file(file_path).to_h
    content = content.except(name).to_yaml
    File.open(file_path, 'w') { |file| file.write(content) }
  end

  def save_in_file
    content = YAML.load_file(file_path) if file_path.exist?
    content ||= {}
    new_content = fixture_is_singular? ? as_save : { name => as_save }
    new_content = JSON.parse(new_content.to_json)
    content.merge!(new_content)
    File.open(file_path, 'w') { |file| file.write(content.to_yaml) }
  end

  def fixture_is_singular?
    fp = file_path.split.last.to_s.delete_suffix('.yml')
    fp.eql?(fp.singularize)
  end

  # Override to provide a path alternative to config/table_name.yml
  def file_path
    Cnfs.project.paths.config.join("#{self.class.table_name}.yml")
  end

  def as_save
    raise NotImplementedError, 'Must return a hash of attributes'
  end

  class << self
    # Public interface; called by models to list the search paths for their config files
    def parse_scopes(*scopes)
      requested = scopes.to_set
      permitted = %i[config environments environment namespace].to_set
      unless requested.subset?(permitted)
        raise ArgumentError, "Invalid key(s) #{requested.difference(permitted).to_a.join(' ')}"
      end

      @parse_scopes ||= Set.new
      @parse_scopes.merge(scopes) # NOTE: Set.merge is equivalent to Hash.merge!
    end

    # Public interface; called by models to list the search sources, e.g. :cli, :plugins, :project, :user
    def parse_sources(*sources)
      requested = sources.to_set
      permitted = Cnfs.source_paths_map.keys.to_set
      unless requested.subset?(permitted)
        raise ArgumentError, "Invalid key(s) #{requested.difference(permitted).to_a.join(' ')}"
      end

      @parse_sources ||= Set.new
      @parse_sources.merge(sources)
    end

    def parse_options(options = {})
      @parse_options ||= {
        config_root: Cnfs.paths.config, # NOTE: For cnfs.yml set join_path to ''
        fixture_name: table_name
      }.with_indifferent_access
      @parse_options.merge!(options)
    end

    # Public interface; loads the class' config files across scopes+sources and optionally yields
    # back to the class on each object added to the configuration fixture
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def parse
      return unless eligible_files
      # TODO: Raise unldess parse_sources.size.positive?

      opts = {}
      opts.merge!(project: Project::PARSE_NAME) if column_names.include?('project_id')
      parse_scopes(:config) if parse_scopes.empty?
      # fixture_file = "#{parse_options[:fixture_name]}.yml"

      sorted_files = pf_map.keys.group_by { |b| b.split('/').size }.sort
      leaf_files = sorted_files.pop.last
      loadable_files = leaf_files.each_with_object({}) do |key, hash|
        hash[key] = []
        path, fn = Pathname.new("./#{key}").split
        path.ascend do |rel_path|
          rel_key = rel_path.join(fn).to_s.delete_prefix('./')
          next unless pf_map.key?(rel_key)

          hash[key].unshift(pf_map[rel_key])
        end
        hash[key].flatten!
      end

      files_loaded = []
      # rubocop:disable Metrics/BlockLength
      output = loadable_files.each_with_object({}) do |(path_key, files), hash|
        Cnfs.logger.info "Loading #{parse_options[:fixture_name]} from #{path_key}"
        Cnfs.logger.debug files.join("\n")
        config = Config.load_files(files).to_hash.deep_stringify_keys
        files_loaded.append(files)
        if parse_scopes.include?(:namespace)
          environment, namespace = path_key.split('/')[1..2]
          namespace_key = "#{environment}_#{namespace}"
          if fixture_is_singular?
            config = { namespace_key => config.merge(opts.merge(name: namespace, environment: environment)) }
          else
            config.each { |key, value| value.merge!(opts.merge(name: key, namespace: namespace_key)) }
            config.transform_keys! { |key| "#{namespace_key}_#{key}" }
          end
        elsif parse_scopes.include?(:environment)
          environment_key = path_key.split('/').second
          if fixture_is_singular?
            config = { environment_key => config.merge(opts.merge(name: environment_key)) }
          else
            merger = column_names.include?('environment_id') ? { environment: environment_key } : {}
            config.each { |key, value| value.merge!(opts).merge!(name: key).merge!(merger) }
            # TODO
            config.transform_keys! { |key| "#{environment_key}_#{key}" }
          end
        elsif parse_scopes.include?(:config)
          if fixture_is_singular?
            # binding.pry
          else
            config.each { |key, value| value&.merge!(opts.merge(name: key)) }
          end
        end
        config = yield(path_key, config, opts) if block_given?
        hash.merge!(config)
      end
      # rubocop:enable Metrics/BlockLength
      create_all(output)
      files_loaded
      # binding.pry if Cnfs.config.is_cli
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity

    def fixture_is_singular?
      fp = parse_options[:fixture_name].to_s
      fp.eql?(fp.singularize)
    end

    def pf_map
      permitted_files.group_by do |path|
        path.delete_prefix(permitted_paths.find { |root_path| path.start_with?(root_path) })
      end
    end

    # Limit eligible files to those found on the parse_sources path(s)
    def permitted_files
      eligible_files.select do |eligible|
        permitted_paths.find { |permitted| eligible.start_with?(permitted) }
      end
    end

    # Files found with a name corresponding to the fixture name
    def eligible_files
      Cnfs.parsable_files[parse_options[:fixture_name].to_s]
    end

    # rubocop:disable Style/MultilineBlockChain
    def permitted_paths
      @permitted_paths ||= begin
        Cnfs.source_paths_map.select do |type|
          parse_sources.include?(type)
        end.values.flatten.map { |path| path.join('config/').to_s }
      end
    end
    # rubocop:enable Style/MultilineBlockChain

    def create_all(content)
      File.open(Cnfs::Configuration.dir.join("#{table_name}.yml"), 'w') do |file|
        file.write(content.deep_stringify_keys.to_yaml)
      end
    end

    def after_parse; end
    # Provides a default empty hash to validate against
    # Override in model to validate against a specific schema
    # def schema
    #   {}
    # end
  end

  # pass in a schema or uses the class default schema
  # usage: validator.valid?(payload hash)
  # See: https://github.com/davishmcclurg/json_schemer
  # def validator(schema = self.class.schema)
  #   JSONSchemer.schema(schema)
  # end
end
# rubocop:enable Metrics/ClassLength
