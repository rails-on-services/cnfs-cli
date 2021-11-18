# frozen_string_literal: true

class Aws::Resource::S3::Bucket < Aws::Resource::S3
  belongs_to :runtime, optional: true

  def valid_types
    super.merge(runtime: 'Runtime::Bucket')
  end
end
