# frozen_string_literal: true

module Concerns
  module Git
    extend ActiveSupport::Concern

    def git_clone(url)
      Command.new(
        # opts: context.options,
        # env: { this: 'that' },
        exec: "git clone #{url}",
        # opts: { printer: :null }
        # opts: context.options.merge(printer: :null)
      )
    end

    def git
      return OpenStruct.new(sha: '', branch: '') unless system('git rev-parse --git-dir > /dev/null 2>&1')

      OpenStruct.new(
        branch: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: `git rev-parse --short HEAD`.chomp,
        tag: `git tag --points-at HEAD`.chomp
      )
    end

    def git_url?(url)
      url.match(git_url_regex)
    end

    # rubocop:disable Layout/LineLength
    def git_url_regex
      %r{^(([A-Za-z0-9]+@|http(|s)://)|(http(|s)://[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|/)([\d/\w.-]+?)(\.git){1}$}i
    end
    # rubocop:enable Layout/LineLength
  end
end
