#!/usr/bin/env ruby
# frozen_string_literal: true

require 'http'
require 'json'
require 'logger'

# Class for interacting with the Ip-Api service to retrieve geolocation data based on an IP address.
class IpApi
  attr_accessor :ip

  # Initialize with the given IP address.
  def initialize(ip, logger)
    @ip = ip
    @logger = logger
  end

  # Run the process to fetch and display geolocation data for the provided IP.
  def run
    # Validate the IP address format before making the request.
    unless valid_ip?(@ip)
      @logger.error('Not a valid IP address!')
      exit 1
    end

    url = "http://ip-api.com/json/#{@ip}"

    begin
      # Make the HTTP request to the IP API service.
      response = HTTP.get(url)

      # Handle the success or failure of the response.
      if response.status.success?
        # Pretty print the JSON response for easier readability.
        json_body = JSON.pretty_generate(response.parse(:json))
        @logger.debug(json_body)
      else
        @logger.error("Failed to retrieve data: #{response.status}")
      end
    rescue HTTP::Error => e
      # Log the error if an HTTP error occurs.
      @logger.error("An error occurred: #{e.message}")
    end
  end

  private

  # Validate the IP address using a regex pattern.
  def valid_ip?(ip)
    /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match?(ip)
  end
end

# Execute the script if it's invoked directly from the command line.
if __FILE__ == $PROGRAM_NAME
  # Create a new Logger instance.
  logger = Logger.new($stdout)
  logger.level = Logger::DEBUG # Set the logging level to DEBUG for detailed logs.

  # Ensure that exactly one argument (IP address) is provided.
  if ARGV.length != 1
    logger.error("Usage: ruby #{$PROGRAM_NAME} <IP_ADDRESS>")
    exit 1
  end

  # Instantiate and run the IpApi class with the provided IP address.
  IpApi.new(ARGV[0], logger).run
end
