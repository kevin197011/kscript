# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/wireguard-password.rb | ruby

require 'bcrypt'

# Class for generating hashed passwords for WireGuard
class WireguardPassword
  DEFAULT_PASSWORD = 'yourpasswordhere'

  attr_reader :password

  # Initialize with password
  # @param password [String] password to hash
  def initialize(password = DEFAULT_PASSWORD)
    @password = password
  end

  # Generate and display hashed password
  def generate
    hashed = hash_password
    display_hash(hashed)
  end

  private

  # Hash the password using BCrypt
  # @return [String] hashed password
  def hash_password
    BCrypt::Password.create(password).gsub('$', '$$')
  end

  # Display the hashed password in environment variable format
  # @param hashed_password [String] hashed password to display
  def display_hash(hashed_password)
    puts "PASSWORD_HASH=#{hashed_password}"
  end
end

WireguardPassword.new.generate if __FILE__ == $PROGRAM_NAME
