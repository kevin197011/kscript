# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/usd-rate.rb | ruby

require 'net/http'
require 'json'

module Kscript
  class KkUsdRate < Base
    API_URL = 'https://api.exchangerate-api.com/v4/latest/USD'

    def run
      with_error_handling do
        fetch_rates
      end
    end

    def fetch_rates
      uri = URI(API_URL)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      logger.info('Fetched USD rates', rates: data['rates'])
      puts JSON.pretty_generate(data['rates'])
    end

    def self.arguments
      '[currency_code]'
    end

    def self.usage
      "kscript usd_rate CNY\nkscript usd_rate EUR"
    end

    def self.group
      'finance'
    end

    def self.author
      'kk'
    end
  end
end

Kscript::KkUsdRate.new.run if __FILE__ == $PROGRAM_NAME
