# frozen_string_literal: true

class Project < Component
  after_create :add_loader

  def add_loader() = CnfsCli.add_loader(name: name, path: Pathname.new('app'))

  # Override Component class methods as this is the 'top level class' in the component hierarch
  def key() = @key ||= super || warn_key

  def key_name() = name

  def key_name_env() = 'CNFS_KEY'

  def warn_key
    Cnfs.logger.error("No encryption key found. Run 'cnfs project generate_key'")
    nil
  end

  def cache_file() = @cache_file ||= CnfsCli.config.cache_home.join("#{name}.yml")

  def data_file() = @data_file ||= CnfsCli.config.data_home.join("#{name}.yml")

  def cache_path() = @cache_path ||= CnfsCli.config.cache_home.join(name)

  def data_path() = @data_path ||= CnfsCli.config.data_home.join(name)

  def attrs() = @attrs ||= [name]

  def as_json() = super.merge('name' => name)

  # called by Node::Component
  # Pathname.new(parent.path).split[0].join('config')
  def dir_path() = 'component'
end
