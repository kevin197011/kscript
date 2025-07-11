# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkMacStatusUtils < Kscript::Base
    def initialize(*_args, **opts)
      super(**opts.merge(service: 'kk_mac_status'))
    end

    def run
      with_error_handling do
        check
      end
    end

    def check
      logger.kinfo('======= 🍎 macOS System Resource Monitor Report =======')
      logger.kinfo("📅 Date Time: #{Time.now}")
      logger.kinfo('')

      # Top 10 by CPU
      print_header('Top 10 Processes by CPU Usage')
      print_process_list(:cpu)
      # Top 10 by Memory
      print_header('Top 10 Processes by Memory Usage')
      print_process_list(:mem)

      # GPU Usage
      if `which powermetrics`.strip.empty?
        logger.kinfo("\n👉 GPU Usage:")
        logger.kwarn('⚠️ powermetrics not installed, please run: xcode-select --install')
      else
        logger.kinfo('===============================')
        logger.kinfo(' GPU Usage')
        logger.kinfo('===============================')
        gpu_output = `sudo powermetrics --samplers gpu_power -n 1 2>/dev/null`
        logger.kinfo(gpu_output)
      end

      # Network Connections
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

      # System Overview
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

    def print_header(title)
      logger.kinfo('')
      logger.kinfo('===============================')
      logger.kinfo(" #{title}")
      logger.kinfo('===============================')
    end

    def print_process_list(sort_field)
      lines = `ps aux`.split("\n")
      lines.shift
      processes = lines.map { |line| line.split(/\s+/, 11) }
      index = sort_field == :cpu ? 2 : 3
      top = processes.sort_by { |p| -p[index].to_f }.first(10)
      logger.kinfo('USER       PID      %CPU  %MEM  COMMAND   ')
      top.each do |p|
        logger.kinfo(format('%-10s %-8s %-5s %-5s %-10s', p[0], p[1], p[2], p[3], p[10][0..30]))
      end
    end

    def self.description
      'Show macOS system resource monitor report.'
    end

    def self.arguments
      ''
    end

    def self.usage
      "kscript mac_status\nkscript mac_status --detail"
    end

    def self.group
      'macos'
    end

    def self.author
      'kk'
    end
  end
end
