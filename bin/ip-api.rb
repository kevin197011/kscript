#!/usr/bin/env ruby
# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/ip-api.rb | ruby

require 'http'
require 'json'

# Class for retrieving geolocation data from IP-API service
class IpGeolocation
  IP_API_BASE_URL = 'http://ip-api.com/json'
  attr_reader :ip_address

  # Initialize with target IP address
  # @param ip_address [String] IP address to lookup
  def initialize(ip_address)
    @ip_address = ip_address
  end

  # Fetch and display geolocation data
  def fetch_location
    validate_ip_address!

    response = make_api_request
    handle_response(response)
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit 1
  end

  private

  # Validate IP address format
  # @raise [ArgumentError] if IP address is invalid
  def validate_ip_address!
    return if valid_ip_format?

    raise ArgumentError, 'Invalid IP address format'
  end

  # Check if IP address matches expected format
  # @return [Boolean] true if format is valid
  def valid_ip_format?
    /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match?(@ip_address)
  end

  # Make HTTP request to IP-API service
  # @return [HTTP::Response] API response
  def make_api_request
    HTTP.get("#{IP_API_BASE_URL}/#{@ip_address}")
  end

  # Handle API response and display results
  # @param response [HTTP::Response] API response to process
  def handle_response(response)
    if response.status.success?
      display_results(response.parse(:json))
    else
      puts "API request failed: #{response.status}"
    end
  end

  # Format and display geolocation results
  # @param data [Hash] parsed JSON response
  def display_results(data)
    puts JSON.pretty_generate(data)
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} <IP_ADDRESS>"
    exit 1
  end

  IpGeolocation.new(ARGV[0]).fetch_location
end
