# frozen_string_literal: true

class Resource::Aws::S3::Bucket::View < ResourceView
  def edit
    # if yes?('Create a new bucket?')
    #   model.name = ask('Budket name:', value: "#{blueprint.name}-#{random_string}")
    # else
      model.name = enum_select('Bucket name:', list_buckets.map(&:name), per_page: list_buckets.size)
    #end
  end
end
