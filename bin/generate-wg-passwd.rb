# frozen_string_literal: true

require 'bcrypt'

password = 'yourpasswordhere'
hashed_password = BCrypt::Password.create(password).gsub('$', '$$')

puts "- PASSWORD_HASH=#{hashed_password}"
