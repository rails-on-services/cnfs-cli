# frozen_string_literal: true

class Project < Component
  after_create :add_loader

  def add_loader
    CnfsCli.add_loader(name: name, path: Pathname.new('app'))
  end

  def key
    @key ||= super || warn_key
  end

  def warn_key
    Cnfs.logger.error("No encryption key found. Run 'cnfs project generate_key'")
    nil
  end

  def as_json
    super.merge('name' => name)
  end

  # called by Node::Component
  # Pathname.new(parent.path).split[0].join('config')
  def dir_path() = 'component'
end
