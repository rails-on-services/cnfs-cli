# frozen_string_literal: true

class Runtime::Service < ApplicationRecord
	belongs_to :runtime

	# accessors match the columns returned by docker ps
	store :docker, coder: YAML, accessors: %i[rid image names command labels status ports]

  class << self
    def create_table(schema)
			schema.create_table table_name, force: true do |t|
				t.references :runtime
				t.string :docker
				t.string :kubernetes
			end
    end
  end
end
