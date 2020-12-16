# frozen_string_literal: true

class Resource::Aws::ACM < Resource::Aws
  def list_certificates
    @list_certificates ||= client.list_certificates.certificate_summary_list
  end
end
