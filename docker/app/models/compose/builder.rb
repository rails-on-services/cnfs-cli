# frozen_string_literal: true

class Compose::Builder < Builder
  def build
    Dir.chdir(path) do
      Cnfs.logger.warn('building!', images.pluck(:name).join(', '), 'END')
      # binding.pry
      # TODO: Use a command object to run docker-compose build
      # rv compose("build --parallel #{images.pluck(:name).join(' ')}")
    end
  end

  def pull
    rv compose("pull #{services.pluck(:name).join(' ')}")
  end

  def push
    rv compose("push #{services.pluck(:name).join(' ')}")
  end

  def test
      Cnfs.logger.warn('testing!', images.pluck(:name).join(', '), 'END')
  end

  private

end
