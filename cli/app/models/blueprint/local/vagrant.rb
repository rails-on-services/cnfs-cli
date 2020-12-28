# frozen_string_literal: true

class Blueprint::Local::Vagrant < Blueprint
  validates :name, presence: true

  # before_validation :setup

  # def setup
  #   self.builder = ::Builder.find_by(name: :vagrant)
  # end

  # TODO: Move this to the vagrant builder
  after_save :provision_machine

  def provision_machine
    builder.provision(self)
  end

  def resource_classes
    [Resource::Local::Instance, Resource::Local::DbInstance, Resource::Local::CacheInstance]
  end

  class << self
    def builder_types
      %w[vagrant]
    end
  end
end
