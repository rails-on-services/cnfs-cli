# frozen_string_literal: true

class Blueprint::Aws < Blueprint
  after_initialize do
    self.source ||= 'git::git@github.com:rails-on-services/terraform-aws-cnfs.git//modules'
  end
end
