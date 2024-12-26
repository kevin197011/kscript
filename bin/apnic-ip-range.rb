# frozen_string_literal: true

require 'http'
require 'uri'

class ApnicIPRange
  attr_reader :country_sn, :cache_file

  # 初始化类的实例，设置国家代码和缓存文件路径
  def initialize(country_sn = 'CN')
    @country_sn = country_sn
    @cache_file = RUBY_PLATFORM.match(/x86_64-linux/) ? '/tmp/apnic.txt' : 'apnic.txt'
  end

  # 从 APNIC 下载数据或读取缓存
  def download_data
    if File.exist?(cache_file) && File.size?(cache_file)
      puts "Using cached data from #{cache_file}"
    else
      url = 'https://ftp.apnic.net/stats/apnic/delegated-apnic-latest'
      response = HTTP.get(url)

      raise "Failed to download the APNIC data. HTTP Status: #{response.status}" unless response.status.success?

      File.write(cache_file, response.body.to_s)
      puts "Data downloaded and saved to #{cache_file}"

    end
  end

  # 解析数据并返回指定国家的 IPv4 地址范围（CIDR 格式）
  def parse_ip_ranges
    download_data # 确保先下载数据

    pattern = /apnic\|#{country_sn}\|ipv4\|(?<ip>\d+\.\d+\.\d+\.\d+)\|(?<hosts>\d+)\|\d+\|allocated/mi
    ip_ranges = []

    File.readlines(cache_file).each do |line|
      next unless line.match(pattern)

      val = line.match(pattern)
      netmask = calculate_netmask(val[:hosts].to_i)
      ip_ranges << "#{val[:ip]}/#{netmask}"
    end

    ip_ranges
  end

  # 根据主机数量计算 CIDR 子网掩码
  def calculate_netmask(hosts)
    # 计算最小的 CIDR 子网掩码
    32 - Math.log2(hosts).to_i
  end
end

if __FILE__ == $PROGRAM_NAME
  # 使用示例：
  apnic = ApnicIPRange.new('CN')
  apnic.parse_ip_ranges.each do |cidr|
    puts cidr
  end
end
