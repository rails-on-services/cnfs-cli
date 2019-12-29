# frozen_string_literal: true

class String
  def _cnfs_encrypted
    start_with?("--- !binary |-\n  ")
  end
  def _cnfs_encrypt
    Cnfs::Core.encrypt(self)
  end
  def _cnfs_decrypt
    _cnfs_encrypted ? Cnfs::Core.decrypt(self) : self
  end
end
