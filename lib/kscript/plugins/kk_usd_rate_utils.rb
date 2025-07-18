# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'httpx'
require 'json'

module Kscript
  class KkUsdRateUtils < Kscript::Base
    API_URL = 'https://api.exchangerate-api.com/v4/latest/USD'

    def initialize(currency_code = 'CNY', *args, **opts)
      super(*args, **opts)
      @currency_code = currency_code
    end

    def run(*args, **_opts)
      with_error_handling do
        @currency_code = args[0] if args[0]
        fetch_rates
      end
    end

    def fetch_rates
      response = HTTPX.get(API_URL)
      response = response.first if response.is_a?(Array)
      data = JSON.parse(response.body.to_s)
      if @currency_code && data['rates'][@currency_code.upcase]
        rate = data['rates'][@currency_code.upcase]
        logger.kinfo("1 USD = #{rate} #{@currency_code.upcase}")
      elsif @currency_code
        logger.kerror("Currency code not found: #{@currency_code}")
      else
        logger.kinfo('USD rates', rates: data['rates'])
      end
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

    def self.description
      'Get latest USD exchange rates.'
    end
  end
end
