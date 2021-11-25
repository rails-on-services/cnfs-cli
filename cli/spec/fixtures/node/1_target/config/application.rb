# frozen_string_literal: true

CnfsCli.configuration do |config|
  config.name = '1_target'
  config.dev = true
  config.components.environment = { aliases: '-e', color: 'yellow', env: 'env' }
  config.components.namespace = { aliases: '-n', color: 'green', env: 'ns' }
  config.components.stack = { aliases: '-s', color: 'green' }
  config.components.target = { aliases: '-t', color: 'blue' }
end
