# frozen_string_literal: true

class Runtime::Skaffold < Runtime
  def labels(base_labels, space_count)
    space_count ||= 12
    base_labels.select { |k, v| v }.map { |key, value| "cnfs.io/#{key.to_s.gsub('_', '-')}: #{value}" }.join("\n#{' ' * space_count}")
  end
end
