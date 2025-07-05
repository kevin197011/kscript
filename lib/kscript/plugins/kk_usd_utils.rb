# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

require 'net/http'
require 'json'

module Kscript
  class KkUsdUtils < Base
    API_URL = 'https://api.exchangerate-api.com/v4/latest/USD'

    def initialize(currency_code = nil, *_args, **opts)
      super(**opts.merge(service: 'kk_usd'))
      @currency_code = currency_code
    end

    def run
      with_error_handling do
        fetch_rates
      end
    end

    def fetch_rates
      uri = URI(API_URL)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      if @currency_code && data['rates'][@currency_code.upcase]
        rate = data['rates'][@currency_code.upcase]
        if human_output?
          logger.kinfo("1 USD = #{rate} #{@currency_code.upcase}")
        else
          logger.kinfo("USD -> #{@currency_code.upcase}", rate: rate)
        end
      elsif @currency_code
        if human_output?
        end
        logger.kerror("Currency code not found: #{@currency_code}")
      elsif human_output?
        logger.kinfo('USD Exchange Rates:')
        data['rates'].each { |k, v| logger.kinfo("  1 USD = #{v} #{k}") }
      else
        logger.kinfo('USD rates', rates: data['rates'])
      end
    end

    def self.arguments
      '[currency_code]'
    end

    def self.usage
      "kscript usd CNY\nkscript usd EUR"
    end

    def self.group
      'finance'
    end

    def self.author
      'kk'
    end

    def self.description
      'Get latest USD exchange rates.'
    end
  end
end
