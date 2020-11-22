# frozen_string_literal: true

# gemspec.rb

gemspec = "#{cnfs.name}.gemspec"
# TODO: use classify and test
klass = cnfs.name.split('-').collect(&:capitalize).join('::')

in_root do
  comment_lines gemspec, 'require '
  gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
  gsub_file gemspec, 'TODO: Write your name', cnfs.username
  gsub_file gemspec, 'TODO: Write your email address', cnfs.email
  gsub_file gemspec, 'TODO: ', ''
  gsub_file gemspec, '~> 10.0', '~> 12.0'
  comment_lines gemspec, /spec\.homepage/
end

create_file 'config/environment.rb'
template 'config/spring.rb' if cnfs.is_engine
