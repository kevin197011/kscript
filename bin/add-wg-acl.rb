#!/usr/bin/env ruby
# frozen_string_literal: true

WHITE_LIST_IPS = %w[
  127.0.0.1
].freeze

PORT = 51_821

# 获取现有 UFW 规则
def current_ufw_rules
  `sudo ufw status`.lines.map(&:strip)
end

# 检查规则是否存在
def rule_exists?(ip, port)
  current_ufw_rules.any? do |line|
    line.match?(/#{Regexp.escape(ip)}.*ALLOW.*#{port}/)
  end
end

# # 检查端口是否已开放（适用于删除前判断）
# def port_allowed?(port)
#   current_ufw_rules.any? { |line| line.match?(/ALLOW.*#{port}/) }
# end

# # 删除已有开放端口规则
# if port_allowed?(PORT)
#   puts "⚠️ 发现已存在 #{PORT} 端口的规则，尝试删除..."
#   system("sudo ufw delete allow #{PORT}")
# else
#   puts "✅ 端口 #{PORT} 没有开放规则，无需删除。"
# end

# 添加白名单规则
WHITE_LIST_IPS.each do |ip|
  if rule_exists?(ip, PORT)
    puts "✅ 规则已存在：#{ip} → #{PORT}，跳过添加。"
  else
    puts "👉 添加规则：允许 #{ip} 访问端口 #{PORT}"
    system("sudo ufw allow from #{ip} to any port #{PORT}")
  end
end

# 确保 ufw 启用
ufw_status = `sudo ufw status`.strip
if ufw_status.start_with?('Status: inactive')
  puts '🔧 ufw 当前未启用，正在启用...'
  system('sudo ufw enable')
else
  puts '✅ ufw 已启用。'
end

# 显示现有规则
puts "\n📋 当前防火墙规则："
system('sudo ufw status verbose')

puts "\n✅ 防火墙规则更新完成！"
