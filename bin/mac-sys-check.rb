# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# !/usr/bin/env ruby

def run(title, cmd, sudo: false)
  puts "\n👉 #{title}"
  puts "$ #{'sudo ' if sudo}#{cmd}"
  output = `#{sudo ? 'sudo ' : ''}#{cmd} 2>&1`
  puts output.strip.empty? ? '(无输出)' : output
rescue StandardError => e
  puts "命令执行失败：#{e.message}"
end

puts '======= 🍎 macOS 系统资源监测报告 ======='
puts "📅 日期时间: #{Time.now}"
puts

# macOS 版本的 ps 命令
cpu_cmd = 'ps aux | sort -nrk 3 | head -n 10'
mem_cmd = 'ps aux | sort -nrk 4 | head -n 10'

run('CPU 使用情况（Top 10）', cpu_cmd)
run('内存使用情况（Top 10）', mem_cmd)

if `which powermetrics`.strip.empty?
  puts "\n👉 GPU 使用情况："
  puts '⚠️ 未安装 powermetrics，请运行: xcode-select --install'
else
  run('GPU 使用情况', 'powermetrics --samplers gpu_power -n 1', sudo: true)
end

puts "\n👉 网络连接最多的前 10 个进程："
lsof_output = `lsof -i -nP | grep ESTABLISHED`
counts = Hash.new(0)
lsof_output.each_line do |line|
  process = line.split.first
  counts[process] += 1
end
counts.sort_by { |_, v| -v }.first(10).each do |proc, count|
  puts "#{proc}: #{count} 个连接"
end

puts "\n👉 系统概况："
cpu_core = `sysctl -n hw.ncpu`.strip
mem_size = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 1024
puts "CPU 核心数: #{cpu_core}"
puts "物理内存: #{mem_size} GB"

vm_stats = `vm_stat`
vm_stats.each_line do |line|
  puts line if line =~ /Pages (active|wired down|free):/
end

puts "\n✅ 系统资源检查完成！"
