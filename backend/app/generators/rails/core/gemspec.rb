# frozen_string_literal: true

gemspec = "#{@profile.name}.gemspec"
klass = @profile.name.split('-').collect(&:capitalize).join('::')

in_root do
  comment_lines gemspec, 'require '
  gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
  gsub_file gemspec, 'TODO: ', ''
  gsub_file gemspec, '~> 10.0', '~> 12.0'
  comment_lines gemspec, /spec\.homepage/
end

create_file 'config/environment.rb'
template 'config/spring.rb' if @profile.is_engine?
