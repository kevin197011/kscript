# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkOptimizeUtils < Base
    def initialize(*args, **opts)
      super(*args, **opts)
    end

    def run(*args, **_opts)
      with_error_handling do
        case args[0]&.to_s
        when 'clean'
          optimize_clean
        when 'speedup'
          optimize_speedup
        when nil, '', 'help', '--help', '-h'
          logger.kwarn("Usage: #{self.class.usage}")
        else
          logger.kerror("Unknown subcommand: #{args[0]}")
          logger.kwarn("Usage: #{self.class.usage}")
        end
      end
    end

    def optimize_clean
      logger.kinfo('🧹 Purging memory cache...')
      system('sudo purge')
      logger.kinfo('✅ Memory cache purged')
    end

    def optimize_speedup
      logger.kinfo('🔧 Starting macOS system optimization...')

      # Lower priority for OrbStack Helper
      orb_pid = `pgrep -f "OrbStack Helper"`.strip
      unless orb_pid.empty?
        logger.kinfo("🛑 Found OrbStack Helper (PID: #{orb_pid}), lowering priority...")
        system("sudo renice +15 #{orb_pid}")
        logger.kinfo('✅ Priority lowered')
      end

      # Close background apps
      apps = ['Telegram', 'Google Chrome']
      apps.each do |app|
        if system("pgrep -x \"#{app}\" > /dev/null")
          logger.kinfo("🛑 Closing #{app}...")
          system("osascript -e 'tell application \"#{app}\" to quit'")
        end
      end

      # Enable Low Power Mode (macOS 12+)
      macos_version = `sw_vers -productVersion`.strip
      if macos_version.split('.').first.to_i >= 12
        logger.kinfo('⚡ Enabling Low Power Mode...')
        system('pmset -a lowpowermode 1')
        logger.kinfo('✅ Low Power Mode enabled')
      else
        logger.kwarn("⚠️ Your macOS version (#{macos_version}) does not support Low Power Mode, skipping.")
      end

      # Show CPU temperature (requires osx-cpu-temp)
      if system('which osx-cpu-temp > /dev/null')
        temp = `osx-cpu-temp`.strip
        logger.kinfo("🌡 Current CPU Temperature: #{temp}")
      else
        logger.kinfo("ℹ️ Install 'osx-cpu-temp' to see CPU temperature (brew install osx-cpu-temp)")
      end

      logger.kinfo('🎉 Optimization complete. Monitor your system for improvements!')
    end

    def self.arguments
      '[subcommand] [options]'
    end

    def self.usage
      "kscript optimize clean\nkscript optimize speedup"
    end

    def self.group
      'macos'
    end

    def self.author
      'kk'
    end

    def self.description
      'Optimize macOS system performance.'
    end
  end
end
