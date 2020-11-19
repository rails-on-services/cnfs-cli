# frozen_string_literal: true

# postgres.rb

remove_file("#{cnfs.app_dir}/config/database.yml")
@database_prefix = cnfs.name.tr('-', '_').to_s
template('config/database.yml', "#{cnfs.app_dir}/config/database.yml")
