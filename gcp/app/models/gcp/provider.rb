# frozen_string_literal: true

class Gcp::Provider < Provider
  store :config, accessors: %i[service_account_key], coder: YAML

  def credentials
    { service_account_key: service_account_key }
  end
end
