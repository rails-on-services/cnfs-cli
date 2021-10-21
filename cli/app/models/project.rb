# frozen_string_literal: true

class Project < Component
  # belongs_to :source_repository, class_name: 'Repository'

  store :config, accessors: %i[paths logging x_components], coder: YAML

  # TODO: Implement validation
  def platform_is_valid
    errors.add(:platform, 'not supported') if Cnfs.platform.unknown?
  end

  def search_path
    Pathname.new(parent.path).split[0].join('config')
  end

  def paths
    @paths ||= super&.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
  end

  def root
    Cnfs.project_root
  end

  # NOTE: Not yet in use; decide where this should go
  # def user_root
  #   @user_root ||= Cnfs.user_root.join(name)
  # end

  def as_save
    base = attributes.slice('name', 'config', 'paths', 'logging')
    # base.merge!('repository' => "#{repository.name} (#{repository.type})") if repository
    base.merge!('repository' => repository.name) if repository
    base
  end

  def command_options
    @command_options ||= x_components.each_with_object([]) do |opt, ary|
      opt = opt.with_indifferent_access
      ary.append({ name: opt[:name].to_sym,
                   desc: opt[:desc] || "Specify #{opt[:name]}",
                   aliases: opt[:aliases],
                   type: :string,
                   default: opt[:default]
      })
    end
  end

  def command_options_list
    @command_options_list ||= x_components.map{ |comp| comp[:name].to_sym }
  end

  # TODO: See what to do about encrypt/decrypt per env/ns

  # Returns an encrypted string
  #
  # ==== Parameters
  # plaintext<String>:: the string to be encrypted
  # scope<String>:: the encryption key to be used: environment or namespace
  def encrypt(plaintext, scope)
    send(scope).encrypt(plaintext)
  end

  def decrypt(ciphertext)
    namespace.decrypt(ciphertext)
  rescue Lockbox::DecryptionError => _e
    environment.decrypt(ciphertext)
  end
end
