# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/mac-top-usage.rb | ruby

# 彩色输出定义
RED    = "\e[1;31m"
GREEN  = "\e[1;32m"
YELLOW = "\e[1;33m"
CYAN   = "\e[1;36m"
NC     = "\e[0m" # No Color

def print_header(title, color)
  puts
  puts "#{color}==============================="
  puts " #{title}"
  puts "===============================#{NC}"
end

def print_process_list(sort_field)
  # 使用 ps 命令获取进程列表
  # aux 输出：USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND
  lines = `ps aux`.split("\n")
  lines.shift # 移除并保存第一行标题
  processes = lines.map { |line| line.split(/\s+/, 11) }

  # 按 %CPU（第3列）或 %MEM（第4列）排序
  index = sort_field == :cpu ? 2 : 3
  top = processes.sort_by { |p| -p[index].to_f }.first(10)

  # 打印表头
  printf "%-10s %-8s %-5s %-5s %-10s\n", 'USER', 'PID', '%CPU', '%MEM', 'COMMAND'

  # 打印每一行
  top.each do |p|
    printf "%-10s %-8s %-5s %-5s %-10s\n", p[0], p[1], p[2], p[3], p[10][0..30]
  end
end

# 主程序开始
puts "#{CYAN}System Resource Top Report - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}#{NC}"

print_header('Top 10 Processes by CPU Usage', RED)
print_process_list(:cpu)

print_header('Top 10 Processes by Memory Usage', GREEN)
print_process_list(:mem)

puts
