# frozen_string_literal: true

class Pathname
  # @return [Boolean] true if rootname is plural, e.g. users
  def plural?() = name.eql?(name.pluralize)

  # @example
  #   Pathname.new('user.yml').singular? # => true
  #   Pathname.new('users.yml').singular? # => false
  # @return [Boolean] true if rootname is singular, e.g. user
  def singular?() = name.eql?(name.singularize)

  # @example
  #   Pathname.new('users.yml').safe_constantize # => User
  def safe_constantize(namespace = nil) = classify(namespace)&.safe_constantize

  # @example
  #   Pathname.new('users.yml').classify # => 'User'
  #   Pathname.new('users.yml').classify('ns') # => 'Ns::User'
  def classify(namespace = nil)
    [namespace, name].compact.join('/').classify unless name.blank?
  end

  # @example
  #   Pathname.new('users.yml').name# => 'users'
  # @return [String] #rootname without the extension
  def name() = @name ||= rootname.end_with?('.') ? rootname.chop : rootname.delete_suffix(".#{extension}")

  # @example
  #   Pathname.new('users.yml').name# => 'yml'
  # @return [String]
  def extension
    @extension ||= begin
      ret_val = rootname.split('.')
      ret_val.size < 2 ? '' : ret_val.last
    end
  end

  # @example
  #    Pathname.new('path/users').rootname # => 'users'
  #    Pathname.new('path/users.yml').rootname # => 'users.yml'
  # @return [String] basename.to_s
  def rootname() = @rootname ||= basename.to_s

  # Simplify call to formatted output of file contents
  def puts() = Kernel.puts(read)

  # Copy to another file
  def cp(dest) = FileUtils.cp(self, dest)
end
