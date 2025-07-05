# frozen_string_literal: true

module Kscript
  # Structured logger for all scripts
  class Logger
    LEVELS = %i[debug info warn error fatal unknown].freeze

    def initialize(service: 'kscript', level: :info, out: $stdout)
      @service = service
      @logger = ::Logger.new(out)
      @logger.level = ::Logger.const_get(level.to_s.upcase)
    end

    LEVELS.each do |level|
      define_method(level) do |message, context = {}|
        log(level, message, context)
      end
    end

    def log(level, message, context = {})
      trace_id = context[:trace_id] || (respond_to?(:default_trace_id) ? default_trace_id : nil) || SecureRandom.hex(8)
      entry = {
        timestamp: Time.now.utc.iso8601,
        level: level.to_s.upcase,
        service: @service,
        message: message,
        trace_id: trace_id,
        context: context.reject { |k, _| k == :trace_id }
      }
      @logger.send(level, entry.to_json)
    end
  end
end
