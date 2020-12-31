# frozen_string_literal: true

class PostProcessor::VagrantS3 < PostProcessor
  store :config, coder: YAML, accessors: %i[
    box_dir box_name manifest version
    bucket profile region
  ]
end
