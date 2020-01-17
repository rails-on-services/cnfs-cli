# frozen_string_literal: true

class Runtime::Native < Runtime
  def before_execute_on_target; switch! end


  def switch!
    response.output.puts 'switch! to be implemented'
  end

  def start
    response.output.puts 'start to be implemented'
  end
end
