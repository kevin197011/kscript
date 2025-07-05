# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkSyscheckUtils < Base
    def run
      with_error_handling do
        check
      end
    end

    def check
      logger.kinfo('======= 🍎 macOS System Resource Monitor Report =======')
      logger.kinfo("📅 Date Time: #{Time.now}")
      logger.kinfo('')

      # macOS ps command for process monitoring
      cpu_cmd = 'ps aux | sort -nrk 3 | head -n 10'
      mem_cmd = 'ps aux | sort -nrk 4 | head -n 10'

      run('CPU Usage (Top 10)', cpu_cmd)
      run('Memory Usage (Top 10)', mem_cmd)

      if `which powermetrics`.strip.empty?
        logger.kinfo("\n👉 GPU Usage:")
        logger.kwarn('⚠️ powermetrics not installed, please run: xcode-select --install')
      else
        run('GPU Usage', 'powermetrics --samplers gpu_power -n 1', sudo: true)
      end

      logger.kinfo("\n👉 Top 10 Processes by Network Connections:")
      lsof_output = `lsof -i -nP | grep ESTABLISHED`
      counts = Hash.new(0)
      lsof_output.each_line do |line|
        process = line.split.first
        counts[process] += 1
      end
      counts.sort_by { |_, v| -v }.first(10).each do |proc, count|
        logger.kinfo("#{proc}: #{count} connections")
      end

      logger.kinfo("\n👉 System Overview:")
      cpu_core = `sysctl -n hw.ncpu`.strip
      mem_size = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 1024
      logger.kinfo("CPU Cores: #{cpu_core}")
      logger.kinfo("Physical Memory: #{mem_size} GB")

      vm_stats = `vm_stat`
      vm_stats.each_line do |line|
        logger.kinfo(line) if line =~ /Pages (active|wired down|free):/
      end

      logger.kinfo("\n✅ System resource check completed!")
    end

    def self.description
      'Show macOS system resource monitor report.'
    end

    def self.arguments
      ''
    end

    def self.usage
      "kscript syscheck\nkscript syscheck --detail"
    end

    def self.group
      'macos'
    end

    def self.author
      'kk'
    end
  end
end
