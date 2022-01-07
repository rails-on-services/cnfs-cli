# frozen_string_literal: true

class Compose::BuilderGenerator < BuilderGenerator
  def compose_yml() = cnfs_template('docker-compose.yml')

  private

  # TODO: If image has a sublcass that needs to invoked for custom rendering
  def yaml_content() = JSON.parse(content.to_json).to_yaml
  # images.first.with_other(git: { 'branch' => 'hello', 'sha' => '1234asd' })

  def content
    {
      version: '3.2',
      services: images_to_hash
    }
  end

  def images_to_hash
    builder.images.each_with_object({}) do |image, hash|
      hash[image.name] = {}
      hash[image.name]['build'] = image.build.merge(labels: labels(image: image.name)).sort.to_h
    end
  end

  def labels(**labels)
    context.labels.merge(labels).transform_keys{|key| "cnfs.io.#{key}"}
  end

  def internal_path() = Pathname.new(__dir__)
end
