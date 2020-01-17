# frozen_string_literal: true

class Runtime::NativeGenerator < RuntimeGenerator

  def generate_project_files
    directory('files', target.write_path(:deployment))

    Dir.chdir(target.write_path(:deployment).join('libexec')) do
      map.each_pair do |src, dest|
        FileUtils.ln_s(dest, src.to_s)
      end
    end

    template('Procfile.infra.erb', "#{target.write_path(:deployment)}/Procfile.infra")
    template('Procfile.erb', "#{target.write_path(:deployment)}/Procfile")
  end

  private

  def map; { _kafka: '_docker', _localstack: '_docker', _sidekiq: '_rails', _spring: '_rails' } end
end
