# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/wireguard-password.rb | ruby

require_relative '../base' unless defined?(Kscript::Base)
require 'bcrypt'

module Kscript
  class KkWireguardPassword < Base
    def run
      with_error_handling do
        generate
      end
    end

    def generate
      password = Array.new(32) { rand(33..126).chr }.join
      logger.info('Generated WireGuard password', password: password)
      puts password
    end

    def self.arguments
      '[length]'
    end

    def self.usage
      "kscript wireguard_password 32\nkscript wireguard_password"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end
  end
end

Kscript::KkWireguardPassword.new.run if __FILE__ == $PROGRAM_NAME
