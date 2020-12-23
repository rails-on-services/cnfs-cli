# frozen_string_literal: true

class Blueprint::Cli::Ansible::Instance < Blueprint

  # The Ansible Instance is running PG, Redis, etc locally which is akin to emulating
  # RDS, ElastiCache, etc in AWS, but running on the local machine
  # This is similar by running docker is something like running EKS cluster
  # TODO: These resources store variables
  # TODO: The view will prompt user for values
  # NOTE: There might not be any values other than yes/no to install/run .e.g docker
  # TODO: Then same cnfs command, e.g. infra apply will be invoked by the user
  # and ansible will be used to provision the infrastructure on the local machine
  # NOTE: Dependencies here are python, pip and ansible; This is similar to depedencies
  # for AWS are terraform, helm, kubectl, aws-cli, eks authenticator, etc
  # TODO: Once this is working then it should be that when creating a new project
  # that the configuration files for development are already setup with this stuff
  def resource_list
    [Resource::Cli::Docker, Resource::Cli::Postgres, Resource::Cli::Redis]
  end

  # TODO: invoke ansible with conifgurations for these resources that ansible can use
  # to provision them; This is very much like using TF to provision an RDS instance
end
