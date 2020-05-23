# frozen_string_literal: true

module Cnfs
  class Application
    CONFIG_FILE = 'application.yml'
    attr_reader :project_name, :root, :user_root, :paths

    def initialize(root)
      @project_name ||= self.class.module_parent.to_s.underscore
      @root = Pathname.new(root)
      @user_root ||= self.class.xdg.config_home.join('cnfs').join(project_name)

      # Load the project's and user's project overrides from application.yml
      Config.load_and_set_settings(paths['config'].map { |path| path.join(CONFIG_FILE) })
    end

    # TODO This would include any dirs from the project directory
    def initialize!
      compile_fixtures
      Cnfs::Schema.setup
    end

    def reload
      compile_fixtures
      Cnfs::Schema.reload
    end

    def path_for(type, sym)
      type = "#{type}_root".to_sym unless type.to_sym.eql?(:root)
      send(type).join(Cnfs::CNFS_DIR).join(sym.to_s)
    end

    def paths
      @paths ||= setup_paths
    end

    def setup_paths
      %w[config db app/views].each_with_object({}) do |path, hsh|
        hsh[path] = [root.join(Cnfs::CNFS_DIR).join(path), user_root.join(Cnfs::CNFS_DIR).join(path)]
      end
    end

    def config; Settings end

    def compile_fixtures
      FileUtils.mkdir_p("#{config.temp_dir}/dump")
      dir = Cnfs.gem_root.join('db')
      fixtures = Dir.chdir(dir) { Dir['**/*.yml'] }.sort
      fixtures.each do |f|
        ar = load_configs(f)
        File.open("#{config.temp_dir}/dump/#{f}", 'w') { |f| f.write(ar) }
      end
    end

    # Utility methods
    # Configuration fixture file loading methods
    def load_configs(file)
      STDOUT.puts "Loading config file #{file}" if Cnfs.debug > 0
      paths['db'].each_with_object([]) { |path, ary| ary << load_config(file, path) }.join("\n")
    end

    def load_config(file, path)
      fixture_file = path.join(File.basename(file))
      return unless File.exist?(fixture_file)

      STDOUT.puts "Loading config file #{fixture_file}" if Cnfs.debug > 0
      ERB.new(IO.read(fixture_file)).result.gsub("---\n", '')
    end

    def self.xdg
      @xdg ||= XDG::Environment.new
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
  end
end
