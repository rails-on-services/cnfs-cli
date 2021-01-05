# frozen_string_literal: true

module ViewHelper
  extend ActiveSupport::Concern

  def list_types(type = 'builder')
    Dir.chdir(CnfsPacker.gem_root.join('app/models')) do
      Dir["#{type}/*.rb"].map{ |file| file.delete_suffix('.rb').classify }
    end
  end
end

