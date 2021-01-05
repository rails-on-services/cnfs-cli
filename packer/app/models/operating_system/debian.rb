# frozen_string_literal: true

class OperatingSystem::Debian < OperatingSystem
  def guest_os_type
    super || 'Debian_64'
  end

  def iso_checksum
    super || iso_data.split.first
  end

  def iso_checksum_type
    super || :md5
  end

  def iso_url
    super || "#{iso_url_base}/#{iso_data.split.last}"
  end

  # rubocop:disable Metrics/AbcSize
  def iso_data
    @iso_data ||= begin
      md5_file = Cnfs.project_root.join(Cnfs.paths.tmp, 'debian_iso_data.txt')
      unless md5_file.exist? # Download file if it doesn't exist in cache
        uri = URI.parse("#{iso_url_base}/MD5SUMS")
        response = Net::HTTP.get_response(uri)
        # response.code
        File.open(md5_file, 'w') { |f| f.write(response.body) }
      end
      File.read(md5_file).split("\n").select { |img| img.end_with?(iso_url_file_name) }.first
    end
  end
  # rubocop:enable Metrics/AbcSize

  def iso_url_base
    'https://cdimage.debian.org/debian-cd/current/amd64/iso-cd'
  end

  def iso_url_file_name
    'amd64-xfce-CD-1.iso'
  end

  def template(generator, builder)
    generator.template('builder/debian/buster64/preseed.cfg', "builders/#{builder.packer_name}/input/preseed.cfg")
  end
end
