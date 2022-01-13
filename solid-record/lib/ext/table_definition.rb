# frozen_string_literal: true

class ActiveRecord::ConnectionAdapters::SQLite3::TableDefinition 
	def solid(*args, **options)
    string(SolidRecord.key_column, type: :string, **options)
    string(SolidRecord.path_column, type: :string, **options)
  end

	def references(*args, **options)
		super(*args, type: :integer, **options)
		if (solid = options.delete(:solid))
			string("#{args.first}_#{SolidRecord.reference_suffix}".to_sym, type: :string, **options)
		end
	end
end
