# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkIpUtils < Base
    IP_API_BASE_URL = 'http://ip-api.com/json'
    IP_CHECK_URL = 'https://api.ipify.org?format=json'

    attr_reader :ip_address

    def initialize(ip_address = nil, *_args, **opts)
      super(**opts.merge(service: 'kk_ip_api'))
      @ip_address = ip_address || fetch_public_ip
    end

    def run
      with_error_handling do
        fetch_location
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
      "kscript ip <ip_address>\nkscript ip 8.8.8.8"
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
      response = HTTP.get(IP_CHECK_URL)
      raise "Failed to detect public IP: #{response.status}" unless response.status.success?

      data = JSON.parse(response.body.to_s)
      logger.info("Detected public IP: #{data['ip']}")
      data['ip']
    end

    def validate_ip_address!
      return if valid_ip_format?

      raise ArgumentError, 'Invalid IP address format'
    end

    def valid_ip_format?
      /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match?(@ip_address)
    end

    def make_api_request
      HTTP.get("#{IP_API_BASE_URL}/#{@ip_address}")
    end

    def handle_response(response)
      if response.status.success?
        logger.kinfo('IP location result', data: response.parse(:json))
      else
        logger.kerror("API request failed: #{response.status}")
      end
    end
  end
end
