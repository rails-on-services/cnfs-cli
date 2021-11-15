# frozen_string_literal: true

class Segment < Component
  def key
    @key ||= local_file_values['key'] || owner&.key
  end

  def generate_key
    local_file_values.merge!('key' => Lockbox.generate_key)
    write_local_file
  end

  def write_local_file
    local_path.split.first.mkpath unless local_path.split.first.exist?
    File.open(local_file, 'w') { |f| f.write(local_file_values.to_yaml) }
  end

  def local_file_values
    @local_file_values ||= local_file.exist? ? (YAML.load_file(local_file) || {}) : {}
  end

  def local_file
    @local_file ||= local_path.split.first.join("#{attrs.last}.yml")
  end

  def local_path
    @local_path ||= CnfsCli.configuration.data_home.join(*attrs)
  end

  def attrs
    @attrs ||= (owner&.attrs || []).dup.append(name)
  end

  def tree_name
    "#{name} (#{c_name})"
  end

  # def x_config
  #   Config::Options.new.merge!(config)
  # end

  def c_name
    owner.segment
  end

  # def except_json
  #   super.append('type')
  # end

  # Display components as a TreeView
  def to_tree
    puts "\n#{as_tree.render}"
  end

  def as_tree
    TTY::Tree.new("#{name} (#{self.class.name.underscore})" => tree)
  end

  def tree
    components.each_with_object([]) do |comp, ary|
      if comp.components.size.zero?
        ary.append("#{comp.name} (#{comp.c_name})")
      else
        ary.append({ "#{comp.name} (#{comp.c_name})" => comp.tree })
      end
    end
  end
end
