# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'httpx'

module Kscript
  class KkApnicIpUtils < Kscript::Base
    attr_reader :country_sn, :cache_file

    # Initialize class instance, set country code and cache file path
    def initialize(country_sn = 'CN', *args, **opts)
      super(*args, **opts)
      @country_sn = country_sn || 'CN'
      @cache_file = RUBY_PLATFORM.match?(/(linux|darwin)/) ? '/tmp/apnic.txt' : 'apnic.txt'
    end

    # Download data from APNIC or read from cache
    def download_data
      if File.exist?(cache_file) && File.size?(cache_file)
        mtime = File.mtime(cache_file)
        if Time.now - mtime < 86_400
          logger.kinfo("Using cached data from #{cache_file} (updated #{mtime})")
          return
        else
          logger.kinfo("Cache expired (last updated #{mtime}), downloading new data...")
        end
      end
      url = 'https://ftp.apnic.net/stats/apnic/delegated-apnic-latest'
      response = HTTPX.get(url)
      response = response.first if response.is_a?(Array)
      raise "Failed to download the APNIC data. HTTP Status: #{response.status}" unless response.status == 200

      File.write(cache_file, response.body.to_s)
      logger.kinfo("Data downloaded and saved to #{cache_file}")
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

      logger.kinfo('IP ranges', ip_ranges: ip_ranges)
      ip_ranges
    end

    # Calculate CIDR netmask based on number of hosts
    def calculate_netmask(hosts)
      # Calculate minimum CIDR netmask
      32 - Math.log2(hosts).to_i
    end

    def run(*args, **_opts)
      with_error_handling do
        @country_sn = args[0] if args[0]
        parse_ip_ranges
      end
    end

    def self.arguments
      '[country_code]'
    end

    def self.usage
      "kscript apnic_ip CN\nkscript apnic_ip US"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end

    def self.description
      'Get APNIC IPv4 ranges for a country.'
    end
  end
end
