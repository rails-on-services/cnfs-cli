# frozen_string_literal: true

class Repository::Git < Repository
  store :config, accessors: %i[url path], coder: YAML

  validates :url, presence: true

  def clone_cmd
    "git clone #{url} #{full_path}"
  end

  def full_path
    return Cnfs.root.join('src', repo_name) unless (npath = path)

    npath = File.expand_path(path) if npath.start_with?('~')
    npath = Pathname.new(npath)
    npath.absolute? ? npath : Cnfs.root.join('src', npath)
  end

  def repo_name
    url.split('/').last.delete_suffix('.git')
  end
end
