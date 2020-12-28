# frozen_string_literal: true

class Blueprint::Local::Instance < Blueprint
  store :config, accessors: %i[blah], coder: YAML

  validates :name, presence: true

  # after_save :clone_repo, unless: -> { packages_path.join('setup').exist? }

  # def clone_repo
  #   builder(:clone_repo) if builder.respond_to?(:clone_repo)
  # end

  # 1. Ansible is the builder. It provisions and configures all requested resources
  # 2. Like with TF, the blueprint has an ERB template which creates the configuration for
  #    the builder (Ansible) to run depending on what the user has selected
  # 3. Once these services are running (PG, Redis, Docker, etc) locally there will be
  #    a runtime interface to them that is compatible with the interface on AWS
  #    E.g. the same command to connect to RDS connects to PG locally
  # 4. Docker = EC2 Instance, PG = RDS, Redis = ElastiCache
  # 5. Dependencies to run ansible (python, pip, ansible) are installed with the same mechansim
  #    as intsalling TF
  # 6. The resource's configuration store variables related to state, e.g. running as well as
  #    runtime information, like DB name, password, host, etc
  # TODO: The view will prompt user for values
  # NOTE: There might not be any values other than yes/no to install/run .e.g docker
  # TODO: Then same cnfs command, e.g. infra apply will be invoked by the user
  # and ansible will be used to provision the infrastructure on the local machine
  # NOTE: Dependencies here are python, pip and ansible; This is similar to depedencies
  # for AWS are terraform, helm, kubectl, aws-cli, eks authenticator, etc
  # TODO: Once this is working then it should be that when creating a new project
  # that the configuration files for development are already setup with this stuff
  def resource_classes
    [Resource::Local::Instance, Resource::Local::DbInstance, Resource::Local::CacheInstance]
  end

  # TODO: invoke ansible with conifgurations for these resources that ansible can use
  # to provision them; This is very much like using TF to provision an RDS instance
  class << self
    def builder_types
      %w[ansible]
    end
  end
end
