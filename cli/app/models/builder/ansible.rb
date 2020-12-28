# frozen_string_literal: true

class Builder::Ansible < Builder

  # after_save :clone_repo, unless: -> { packages_path.join('setup').exist? }

  class << self
    def clone_repo
      return if packages_path.join('setup').exist?

      Dir.chdir(packages_path) do
        system('git clone https://github.com/rails-on-services/setup')
      end
    end

    def packages_path
      packages_path = Cnfs.user_data_root.join('packages')
      packages_path.mkpath unless packages_path.exist?
      packages_path
    end
  end
end
