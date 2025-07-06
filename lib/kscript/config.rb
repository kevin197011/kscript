# frozen_string_literal: true

# Kscript::Config
# Responsible for loading ~/.kscript/.env and providing config access
# Usage:
#   Kscript::Config.load!
#   Kscript::Config.get('AWS_ACCESS_KEY_ID')

require 'dotenv'

module Kscript
  module Config
    CONFIG_PATH = File.expand_path('~/.kscript/.env')
    @loaded = false

    # Load ~/.kscript/.env using dotenv
    def self.load!
      return if @loaded

      Dotenv.load(CONFIG_PATH)
      @loaded = true
    end

    # Get config value from ENV, with optional default
    # @param key [String] ENV key
    # @param default [Object] default value if not set
    def self.get(key, default = nil)
      ENV[key] || default
    end
  end
end
