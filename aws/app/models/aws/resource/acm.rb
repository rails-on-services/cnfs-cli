# frozen_string_literal: true

class Aws::Resource::ACM < Aws::Resource
  def list_certificates
    @list_certificates ||= client.list_certificates.certificate_summary_list
  end
end
