# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/apnic-ip-range.rb | ruby

require 'kscript'
require 'http'
require 'uri'
require 'kscript/base'

module Kscript
  class KkApnicUtils < Base
    attr_reader :country_sn, :cache_file

    # Initialize class instance, set country code and cache file path
    def initialize(country_sn = 'CN')
      @country_sn = country_sn
      @cache_file = RUBY_PLATFORM.match(/x86_64-linux/) ? '/tmp/apnic.txt' : 'apnic.txt'
    end

    # Download data from APNIC or read from cache
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

    # Parse data and return IPv4 address ranges (CIDR format) for specified country
    def parse_ip_ranges
      download_data # Ensure data is downloaded first

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

    # Calculate CIDR netmask based on number of hosts
    def calculate_netmask(hosts)
      # Calculate minimum CIDR netmask
      32 - Math.log2(hosts).to_i
    end

    def run
      with_error_handling do
        parse_ip_ranges
      end
    end

    def self.arguments
      '[country_code]'
    end

    def self.usage
      "kscript apnic_ip_range CN\nkscript apnic_ip_range US"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end
  end
end
