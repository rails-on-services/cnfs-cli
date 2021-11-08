# frozen_string_literal: true

group :rgf, halt_on_fail: true do # red_green_refactor
  guard :rspec, cmd: 'rspec' do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb') { 'spec' }
  end

  guard :rubocop, all_on_start: false, notification: true do
    watch(%r{^spec/models/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})
    watch(%r{^app/(.+)\.rb$})
  end
end

notification :tmux,
  display_message: true,
  change_color: true

# notification :tmux,
#   display_message: true,
#   timeout: 5, # in seconds
#   default_message_format: '%s >> %s',
#   # the first %s will show the title, the second the message
#   # Alternately you can also configure *success_message_format*,
#   # *pending_message_format*, *failed_message_format*
#   line_separator: ' > ', # since we are single line we need a separator
#   color_location: 'status-left-bg', # to customize which tmux element will change color
#
#   # Other options:
#   default_message_color: 'black',
#   # success: 'colour150',
#   # failure: 'colour174',
#   # pending: 'colour179',
#   success: 'green',
#   failure: 'red',
#   pending: 'yellow',
#
#   # Notify on all tmux clients
#   display_on_all_clients: false,
#   color_location: %w[status-left-bg pane-active-border-fg pane-border-fg]

# notification(:tmux, {
#   display_title: true,
#   display_on_all_clients: true,
#   success: 'colour150',
#   failure: 'colour174',
#   pending: 'colour179',
#   color_location: %w[status-left-bg pane-active-border-fg pane-border-fg],
# }) if ENV['TMUX']
