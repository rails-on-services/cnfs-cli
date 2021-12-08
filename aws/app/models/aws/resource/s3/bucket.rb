# frozen_string_literal: true

class Aws::Resource::S3::Bucket < Aws::Resource::S3
  belongs_to :runtime, optional: true

  store :config, accessors: %i[arn]

  def valid_types() = super.merge(runtime: 'Bucket::Runtime')
end
