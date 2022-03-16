# frozen_string_literal: true

class Gcp::Provider < OneStack::Provider
  store :config, accessors: %i[service_account_key]

  def credentials() = { service_account_key: service_account_key }
end
