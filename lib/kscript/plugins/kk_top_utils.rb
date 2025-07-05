# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/mac-top-usage.rb | ruby

require 'kscript'

# 彩色输出定义
RED    = "\e[1;31m"
GREEN  = "\e[1;32m"
YELLOW = "\e[1;33m"
CYAN   = "\e[1;36m"
NC     = "\e[0m" # No Color

module Kscript
  class KkTopUtils < Base
    def run
      with_error_handling do
        print_report
      end
    end

    def print_report
      puts "System Resource Top Report - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
      print_header('Top 10 Processes by CPU Usage')
      print_process_list(:cpu)
      print_header('Top 10 Processes by Memory Usage')
      print_process_list(:mem)
    end

    def print_header(title)
      puts
      puts '==============================='
      puts " #{title}"
      puts '==============================='
    end

    def print_process_list(sort_field)
      lines = `ps aux`.split("\n")
      lines.shift
      processes = lines.map { |line| line.split(/\s+/, 11) }
      index = sort_field == :cpu ? 2 : 3
      top = processes.sort_by { |p| -p[index].to_f }.first(10)
      printf "%-10s %-8s %-5s %-5s %-10s\n", 'USER', 'PID', '%CPU', '%MEM', 'COMMAND'
      top.each do |p|
        printf "%-10s %-8s %-5s %-5s %-10s\n", p[0], p[1], p[2], p[3], p[10][0..30]
      end
    end

    def self.description
      'Show top 10 processes by CPU/memory on macOS.'
    end

    def self.arguments
      ''
    end

    def self.usage
      'kscript mac_top_usage'
    end

    def self.group
      'macos'
    end

    def self.author
      'kk'
    end
  end
end

Kscript::KkTopUtils.new.run if __FILE__ == $PROGRAM_NAME
