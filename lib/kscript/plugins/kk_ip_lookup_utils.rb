# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkIpLookupUtils < Base
    IP_API_BASE_URL = 'http://ip-api.com/json'
    IP_CHECK_URL = 'https://api.ipify.org?format=json'

    attr_reader :ip_address

    def initialize(*args, **opts)
      super
      @ip_address = args.first || fetch_public_ip
    end

    def run(*args, **_opts)
      with_error_handling do
        ip = args.first || @ip_address
        validate_ip_address!(ip)
        response = make_api_request(ip)
        handle_response(response)
      end
    end

    def fetch_location
      validate_ip_address!
      response = make_api_request
      handle_response(response)
    end

    def self.arguments
      '<ip_address>'
    end

    def self.usage
      "kscript ip_lookup <ip_address>\nkscript ip_lookup 8.8.8.8"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end

    def self.description
      'Query IP geolocation and ISP info.'
    end

    private

    def fetch_public_ip
      begin
        require 'httpx'
      rescue LoadError
        abort 'Missing dependency: httpx. Please run: gem install httpx'
      end
      response = HTTPX.get(IP_CHECK_URL)
      response = response.first if response.is_a?(Array)
      raise "Failed to detect public IP: #{response.status}" unless response.status == 200

      data = JSON.parse(response.body.to_s)
      logger.kinfo("Detected public IP: #{data['ip']}")
      data['ip']
    end

    def validate_ip_address!(ip)
      return if valid_ip_format?(ip)

      raise ArgumentError, 'Invalid IP address format'
    end

    def valid_ip_format?(ip)
      /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match?(ip)
    end

    def make_api_request(ip)
      begin
        require 'httpx'
      rescue LoadError
        abort 'Missing dependency: httpx. Please run: gem install httpx'
      end
      response = HTTPX.get("#{IP_API_BASE_URL}/#{ip}")
      response.is_a?(Array) ? response.first : response
    end

    def handle_response(response)
      if response.status == 200
        logger.kinfo('IP location result', data: JSON.parse(response.body.to_s))
      else
        logger.kerror("API request failed: #{response.status}")
      end
    end
  end
end
