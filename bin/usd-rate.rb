#!/usr/bin/env ruby
# frozen_string_literal: true

require 'http'
require 'json'

# Class to fetch and display the latest USD exchange rates from an external API.
class USDRate
  # Main method that fetches and processes the exchange rate data.
  def run
    # API endpoint to get the latest USD exchange rates.
    url = 'https://api.exchangerate-api.com/v4/latest/USD'

    begin
      # Send GET request to the API.
      response = HTTP.get(url)

      # If the request was successful, parse and pretty-print the response.
      if response.status.success?
        data = response.parse(:json)
        json_body = JSON.pretty_generate(data)
        puts json_body
      else
        # If the API request fails, output the failure status.
        puts "Failed to retrieve data: #{response.status}"
      end
    rescue HTTP::Error => e
      # In case of an HTTP error, display the error message.
      puts "An error occurred: #{e.message}"
    end
  end
end

# Ensure that the script runs only when invoked directly.
USDRate.new.run if __FILE__ == $PROGRAM_NAME
