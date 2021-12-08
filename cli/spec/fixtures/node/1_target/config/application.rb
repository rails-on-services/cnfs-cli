# frozen_string_literal: true

CnfsCli.configuration do |config|
  config.name = '1_target'
  config.dev = true

  config.project_id = 'ce676155-a3ec-4541-a921-e1327df0b56b'

  config.segments.environment = { aliases: '-e', color: 'yellow', env: 'env' }
  config.segments.namespace = { aliases: '-n', color: 'green', env: 'ns' }
  config.segments.stack = { aliases: '-s', color: 'green' }
  config.segments.target = { aliases: '-t', color: 'blue' }
end
