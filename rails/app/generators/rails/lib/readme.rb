# frozen_string_literal: true

# readme.rb

append_to_file 'README.md' do
  <<~RUBY
    # Documentation
    [Rails on Services Guides](https://guides.rails-on-services.org)
  RUBY
end
