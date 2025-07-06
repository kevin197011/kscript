# frozen_string_literal: true

# Kscript::Config
# Responsible for loading ~/.kscript/.env and providing config access
# Usage:
#   Kscript::Config.load!
#   Kscript::Config.get('AWS_ACCESS_KEY_ID')

module Kscript
  module Config
    CONFIG_PATH = File.expand_path('~/.kscript/.env')
    @loaded = false

    # Load ~/.kscript/.env and set ENV variables
    def self.load!
      return if @loaded
      return unless File.exist?(CONFIG_PATH)

      File.readlines(CONFIG_PATH).each do |line|
        line.strip!
        next if line.empty? || line.start_with?('#')

        next unless line =~ /\A([A-Za-z_][A-Za-z0-9_]*)=(.*)\z/

        key = Regexp.last_match(1)
        val = Regexp.last_match(2).strip
        # Remove surrounding quotes if present
        val = val[1..-2] if val.start_with?('"', "'") && val.end_with?('"', "'")
        ENV[key] = val
      end
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
