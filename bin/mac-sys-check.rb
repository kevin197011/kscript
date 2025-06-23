# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/mac-sys-check.rb | ruby

def run(title, cmd, sudo: false)
  puts "\n👉 #{title}"
  puts "$ #{'sudo ' if sudo}#{cmd}"
  output = `#{sudo ? 'sudo ' : ''}#{cmd} 2>&1`
  puts output.strip.empty? ? '(no output)' : output
rescue StandardError => e
  puts "Command execution failed: #{e.message}"
end

puts '======= 🍎 macOS System Resource Monitor Report ======='
puts "📅 Date Time: #{Time.now}"
puts

# macOS ps command for process monitoring
cpu_cmd = 'ps aux | sort -nrk 3 | head -n 10'
mem_cmd = 'ps aux | sort -nrk 4 | head -n 10'

run('CPU Usage (Top 10)', cpu_cmd)
run('Memory Usage (Top 10)', mem_cmd)

if `which powermetrics`.strip.empty?
  puts "\n👉 GPU Usage:"
  puts '⚠️ powermetrics not installed, please run: xcode-select --install'
else
  run('GPU Usage', 'powermetrics --samplers gpu_power -n 1', sudo: true)
end

puts "\n👉 Top 10 Processes by Network Connections:"
lsof_output = `lsof -i -nP | grep ESTABLISHED`
counts = Hash.new(0)
lsof_output.each_line do |line|
  process = line.split.first
  counts[process] += 1
end
counts.sort_by { |_, v| -v }.first(10).each do |proc, count|
  puts "#{proc}: #{count} connections"
end

puts "\n👉 System Overview:"
cpu_core = `sysctl -n hw.ncpu`.strip
mem_size = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 1024
puts "CPU Cores: #{cpu_core}"
puts "Physical Memory: #{mem_size} GB"

vm_stats = `vm_stat`
vm_stats.each_line do |line|
  puts line if line =~ /Pages (active|wired down|free):/
end

puts "\n✅ System resource check completed!"
