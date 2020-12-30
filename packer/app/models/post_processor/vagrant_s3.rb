# frozen_string_literal: true

class PostProcessor::VagrantS3 < PostProcessor
  store :config, accessors: %i[box_dir box_name manifest version]
  store :config, accessors: %i[bucket profile region]
end
