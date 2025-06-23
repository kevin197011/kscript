# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/usd-rate.rb | ruby

require 'http'
require 'json'

# Class for fetching USD exchange rates from exchangerate-api.com
class UsdRateFetcher
  API_URL = 'https://api.exchangerate-api.com/v4/latest/USD'

  # Fetch and display the latest USD exchange rates
  def fetch_rates
    response = make_request
    process_response(response)
  rescue HTTP::Error => e
    display_error(e)
  end

  private

  # Make HTTP request to exchange rate API
  # @return [HTTP::Response] API response
  def make_request
    HTTP.get(API_URL)
  end

  # Process and display API response
  # @param response [HTTP::Response] response from API
  def process_response(response)
    if response.status.success?
      display_rates(response.parse(:json))
    else
      puts "Failed to retrieve data: #{response.status}"
    end
  end

  # Display formatted exchange rates
  # @param data [Hash] parsed JSON response
  def display_rates(data)
    puts JSON.pretty_generate(data)
  end

  # Display error message
  # @param error [StandardError] error to display
  def display_error(error)
    puts "An error occurred: #{error.message}"
  end
end

UsdRateFetcher.new.fetch_rates if __FILE__ == $PROGRAM_NAME
