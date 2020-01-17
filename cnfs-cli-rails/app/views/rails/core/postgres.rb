# core/rails/postgres.rb

remove_file "#{@profile.app_dir}/config/database.yml"
@database_prefix = "#{@profile.service_name.tr('-', '_')}"
template 'config/database.yml', "#{@profile.app_dir}/config/database.yml"
