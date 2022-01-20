# frozen_string_literal: true

require 'active_support/inflector'

class Pathname
  # Argument is a string or Pathname
  # Returns a Pathname when matched or nil
  def matchpath(path_map)
    return unless (str = last_element_match(path_map))

    Pathname.new(str)
  end

  # returns argument's path element in position one less than the size of the path elements
  # path_map, self.to_s, result
  # 'stacks/environments/targets', 'foo/bar/baz', 'targets'
  # 'stacks/environments/targets', 'foo/bar', 'environments'
  # 'stacks/environments/targets', 'foo', 'stacks'
  def last_element_match(path_map) = path_map.to_s.split('/')[last_element_index]

  # 'foo/bar/baz' => 2, 'foo/bar' => 1, 'foo' => 0
  def last_element_index() = to_s.split('/').size - 1

  # returns true if rootname is users or users.yml
  def plural?() = name.eql?(name.pluralize)

  # returns true if rootname is user or user.yml
  def singular?() = name.eql?(name.singularize)

  # users.yml => User
  def safe_constantize() = classify.safe_constantize

  # Root name functionality
  # users.yml => 'User'
  def classify() = name.classify

  # users.yml => users
  def name() = @name ||= rootname.delete_suffix(".#{extension}")

  # users.yml => yml
  def extension() = @extension ||= rootname.split('.').last

  # Pathname.new('path/users.yml').rootname => 'users.yml'
  def rootname() = @rootname ||= basename.to_s
end
