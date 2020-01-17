# frozen_string_literal: true

class Runtime::Native < Runtime
  def before_execute_on_target; switch! end


  def switch!
    response.output.puts 'switch! to be implemented'
  end

  def start
    response.output.puts 'start to be implemented'
  end

  def native(command)
    system(env, command)
  end

  def env
    {
      DB_DIR: '${DB_DIR:-$(realpath $DATA_DIR/db)',
      DB_PORT: '${DB_PORT:-5432}',
      DB_SOCKET: '${DB_SOCKET:-$DB_DIR/.s.PGSQL.$DB_PORT}',
      REDIS_DIR: '${REDIS_DIR:-$(realpath $DATA_DIR/redis)}',
      RUN_DIR: '${RUN_DIR:-${XDG_RUNTIME_DIR:-$(realpath $DATA_DIR/run)}}',
      OVERMIND_SOCKET: '${OVERMIND_SOCKET:-${RUN_DIR}/overmind/$(basename $(pwd)).sock}',
      LOG_DIR: '$(realpath $DATA_DIR/log)',
      PLATFORM_PATH: '${PLATFORM_PATH:-perx/whistler-services/services}'
    }
  end
end
