# frozen_string_literal: true

module Backend
  class AddController
    attr_accessor :name, :type, :options

    def initialize(type, name, options)
      @type = type
      @name = name
      @options = options
    end

    # NOTE: For now there is only one type which is 'service'
    # TODO: Take an option which is the invoke or revoke
    # TODO: Maybe change the name to ModifyController
    def execute
      generator = "Backend::#{type.classify}Generator".safe_constantize.new([name], options)
      generator.destination_root = Cnfs.application.root
      generator.behavior = :revoke if options.revoke
      generator.invoke_all
    end
  end
end
