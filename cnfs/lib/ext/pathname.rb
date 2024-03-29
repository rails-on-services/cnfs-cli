# frozen_string_literal: false

class Pathname
  def puts() = Kernel.puts(read)

  def cp(dest) = FileUtils.cp(self, dest)
end

class Array
  # Support multiple options to filter an array of Hashes
  def where(**options)
    ret_val = self
    options.each do |key, value|
      ret_val = ret_val.select{ |item| item[key].eql?(value.to_s) }
    end
    ret_val
  end
end
