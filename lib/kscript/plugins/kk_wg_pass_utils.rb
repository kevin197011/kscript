# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'
require 'bcrypt'

module Kscript
  class KkWgPassUtils < Base
    def initialize(length = 32, *_args, **opts)
      super(**opts.merge(service: 'kk_wg_pass'))
      @length = length.to_i
    end

    def run
      with_error_handling do
        generate
      end
    end

    def generate
      password = Array.new(@length) { rand(33..126).chr }.join
      logger.kinfo('Generated WireGuard password', password: password)
      logger.kinfo(password)
    end

    def self.arguments
      '[length]'
    end

    def self.usage
      "kscript wg_pass [length]\nkscript wg_pass 32"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end

    def self.description
      'Generate a random password for WireGuard.'
    end
  end
end
