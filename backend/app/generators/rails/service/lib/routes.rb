# frozen_string_literal: true

inject_into_file cnfs.routes_file, after: "routes.draw do\n" do
  <<-RUBY
  extend Ros::Routes
  mount Ros::Core::Engine => '/'
  RUBY
end

inject_into_file cnfs.routes_file, before: /^end/ do
  <<-RUBY
  catch_not_found
  RUBY
end
