# frozen_string_literal: true

class PostProcessor::Vagrant < PostProcessor
  store :config, accessors: %i[keep_input_artifact output]
end
