# frozen_string_literal: true

class String
  def _cnfs_encrypted?; start_with?("--- !binary |-\n  ") end

  def _cnfs_ciphertext; Cnfs.encrypt(self) end

  def _cnfs_plaintext; _cnfs_encrypted? ? Cnfs.decrypt(self) : self end
end
