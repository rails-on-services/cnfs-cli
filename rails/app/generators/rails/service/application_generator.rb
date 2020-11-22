# frozen_string_literal: true

# in_root is the actual root
# 1. application stand alone
# 2. application that wraps a plugin from a plugin repository

# Development Gemfile
template('Gemfile.dev.erb', 'Gemfile.dev')
# Production Gemfile
template('Gemfile.prod.erb', 'Gemfile.prod')

# From core generator:
remove_file('Gemfile')
create_file('Gemfile')
# TODO: gems may by only for the core gem since the service rely on the parent Gemfile
# apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')

# Modify spec/dummy or app Base Classes
apply('app_classes.rb')
apply('initializers.rb')

apply('routes.rb')
template('app/models/tenant.rb')

# Write seed files for tenants, etc
template('db/seeds/development/tenants.seeds.rb')
template('db/seeds/development/data.seeds.rb')

template('config/sidekiq.yml')
template('doc/open_api.yml')

apply('rspec.rb')
# binding.pry

FileUtils.mv('Gemfile', 'Gemfile.dev.txt')
directory('files', '.')
after_bundle do
  generate 'rspec:install'
  run 'spring stop'
end

# copy_file 'defaults/files/Procfile', 'Procfile'
# template 'defaults/files/tmuxinator.yml', '.tmuxinator.yml'
