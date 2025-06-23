# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/mac-optimize.rb | ruby

require 'open3'

puts '🔧 Starting macOS system optimization...'

# Lower priority for OrbStack Helper
orb_pid = `pgrep -f "OrbStack Helper"`.strip
unless orb_pid.empty?
  puts "🛑 Found OrbStack Helper (PID: #{orb_pid}), lowering priority..."
  system("sudo renice +15 #{orb_pid}")
  puts '✅ Priority lowered'
end

# Close background apps
apps = ['Telegram', 'Google Chrome']
apps.each do |app|
  if system("pgrep -x \"#{app}\" > /dev/null")
    puts "🛑 Closing #{app}..."
    system("osascript -e 'tell application \"#{app}\" to quit'")
  end
end

# Purge memory cache
puts '🧹 Purging memory cache...'
system('sudo purge')
puts '✅ Memory cache purged'

# Enable Low Power Mode (macOS 12+)
macos_version = `sw_vers -productVersion`.strip
if macos_version.split('.').first.to_i >= 12
  puts '⚡ Enabling Low Power Mode...'
  system('pmset -a lowpowermode 1')
  puts '✅ Low Power Mode enabled'
else
  puts "⚠️ Your macOS version (#{macos_version}) does not support Low Power Mode, skipping."
end

# Show CPU temperature (requires osx-cpu-temp)
if system('which osx-cpu-temp > /dev/null')
  temp = `osx-cpu-temp`.strip
  puts "🌡 Current CPU Temperature: #{temp}"
else
  puts "ℹ️ Install 'osx-cpu-temp' to see CPU temperature (brew install osx-cpu-temp)"
end

puts '🎉 Optimization complete. Monitor your system for improvements!'
