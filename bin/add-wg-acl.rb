#!/usr/bin/env ruby
# frozen_string_literal: true

# 定义允许访问的白名单 IP
WHITE_LIST_IPS = %w[
  127.0.0.1
].freeze

PORT = 51_821

# 先删除所有现有的规则（针对51821端口）
system("sudo ufw delete allow #{PORT}")

# 逐个添加白名单 IP 访问权限
WHITE_LIST_IPS.each do |ip|
  system("sudo ufw allow from #{ip} to any port #{PORT}")
  puts "允许 IP: #{ip} 访问端口 #{PORT}"
end

# 确保 ufw 启用
system('sudo ufw enable')

# 显示当前 ufw 规则
system('sudo ufw status verbose')

puts '✅ 防火墙规则更新完成！'
