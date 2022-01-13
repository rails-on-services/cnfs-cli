# frozen_string_literal: true

class Pathname
  # users/blogs.yml => users/blogs
  def keyname() = @keyname ||= realpath.to_s.delete_suffix(".#{extension}")

  # users.yml => users
  def name() = @name ||= rootname.delete_suffix(".#{extension}")

  # users.yml => yml
  def extension() = @extension ||= rootname.split('.').last

  # Pathname(path/users.yml) => users.yml
  def rootname() = @rootname ||= basename.to_s

  # Root name functionality
  # users.yml => User
  def classify() = name.classify

  # true if file name is user or user.yml
  def singular?() = name.eql?(name.singularize)

  # Read
  def read_asset() = send("read_#{parser}")

  def read_raw() = read

  def read_yaml() = YAML.load_file(self)

  # Write a Hash to the file
  # TODO: Is there a better way to do it?
  def write_asset(content) = send("write_#{parser}", content)

  def write_raw(content) = write(content)

  def write_yaml(content) = write(content.to_yaml)

  # Parser
  def parser() = SolidRecord.parser || SolidRecord.parser_map[extension.to_sym] || :raw
end
