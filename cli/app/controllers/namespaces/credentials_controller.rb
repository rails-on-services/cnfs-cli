# frozen_string_literal: true

module Namespaces
  class CredentialsController < ApplicationController
    def execute
      each_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      FileUtils.mkdir_p(local_path)
      runtime.copy("iam:#{remote_file}", local_file) unless File.exist?(local_file)
      response.run!
      output.puts credentials
    end

    def credentials
      credentials = json.each_with_object([]) { |j, a| a.append(Credential.new(j, target)) }
      if options.format.nil?
        credentials.map(&:to_env).flatten.join("\n")
      elsif options.format.eql?('sdk')
        credentials.map(&:to_sdk)
      elsif options.format.eql?('cli')
        credentials.map(&:to_cli)
      elsif options.format.eql?('postman')
        credentials.map(&:to_postman)
      end
    end

    def remote_file
      runtime.credentials[:remote_file]
    end

    def local_file
      runtime.credentials[:local_file]
    end

    def local_path
      runtime.credentials[:local_path]
    end
    # def remote_file; "/home/rails/services/app/tmp/#{'mounted'}/credentials.json" end

    # def local_file; "#{local_path}/credentials.json" end

    # def local_path; "#{target.write_path(:runtime)}/target" end

    def json
      File.exist?(local_file) ? JSON.parse(File.read(local_file)) : []
    end
  end

  class Credential
    attr_accessor :type, :owner, :tenant, :credential, :secret, :target, :application

    def initialize(json, target)
      self.type = json['type']
      self.owner = json['owner']
      self.tenant = json['tenant']
      self.credential = json['credential']
      self.secret = json['secret']
      self.target = target
      self.application = target.application
    end

    def to_env
      Config::Options.new.merge!(
        'platform' => {
          'tenant' => {
            tenant['id'].to_s => {
              type.to_s => {
                owner['id'].to_s => "Basic #{credential['access_key_id']}:#{secret}"
              }
            }
          }
        }
      ).to_array
    end

    def to_cli
      "[#{identifier}]\n" \
        "#{part_name}_access_key_id=#{credential['access_key_id']}\n" \
        "#{part_name}_secret_access_key=#{secret}"
    end

    def to_sdk
      "Ros::Sdk::Credential.authorization='Basic #{credential['access_key_id']}:#{secret}'"
    end

    def to_postman
      # TODO: password is not serialized
      {
        name: identifier,
        values: [
          { key: :authorization, value: "Basic #{credential['access_key_id']}:#{secret}" },
          { key: uid, value: owner[uid] },
          { key: :password, value: owner['password'] }
        ]
      }
    end

    def identifier
      "#{tenant_account_id}-#{cred_uid}"
    end

    def uid
      type.eql?('root') ? 'email' : 'username'
    end

    def cred_uid
      type.eql?('root') ? owner['email'].split('@').first : owner['username']
    end

    def part_name
      application.partition_name(target.application_environment)
    end

    def tenant_account_id
      tenant['urn'].split('/').last
    end
  end
end
