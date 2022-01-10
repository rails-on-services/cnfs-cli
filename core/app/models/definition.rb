# frozen_string_literal: true

class Definition < ApplicationRecord
  include Concerns::Generic

  store :config, accessors: :path

  before_validation :set_defaults

  def set_defaults
    self.name = path.split('/').last
    self.owner = SegmentRoot.create(name: :test)
  end

  after_create :do_it

  attr_reader :mod, :parent_class, :class_name

  def do_it
    parse_attributes
    create_class
  end

  def parse_attributes
    asset_type, *mod_types, model_type = file.to_s.delete_suffix('.yml').split('/').map(&:classify)
    @mod = mod_types.join('::').safe_constantize || Object
    @class_name = [model_type, asset_type].join
    @parent_class = asset_type.safe_constantize
  end

  # services/nginx.yml => NginxService
  # plans/terraform/ec2.yml # => Terraform::Ec2Plan
  def create_class
    attributes = content['attributes']
    mod.const_set class_name, Class.new(parent_class) {
      attr_accessor(*attributes)
      # include Concerns::Extendable
    }
  end

  def content() = @content ||= YAML.load_file(path)

  # TODO: The DefinitionFile should be passed in and it is relative from there somehow
  # so that definitions are in extensions as well
  def file() = pathname.relative_path_from(Cnfs.config.paths.definitions)

  def pathname() = @pathname ||= Pathname.new(path)
end
