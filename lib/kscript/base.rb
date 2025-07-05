# frozen_string_literal: true

module Kscript
  # Base class for all kscript scripts
  class Base
    attr_reader :logger

    def initialize(service: nil, log_level: nil, trace_id: nil)
      config = defined?(Kscript::Utils::Config) ? Kscript::Utils::Config.load : nil
      log_level ||= config&.log_level || ENV['KSCRIPT_LOG_LEVEL'] || :info
      trace_id ||= config&.trace_id || ENV['KSCRIPT_TRACE_ID']
      @trace_id = trace_id
      @logger = Kscript::Logger.new(service: service || self.class.name, level: log_level)
    end

    # 通用工具方法可在此扩展
    def with_error_handling
      yield
    rescue StandardError => e
      logger.error("Unhandled error: #{e.class} - #{e.message}", error: e.class.name, backtrace: e.backtrace&.first(5))
      exit(1)
    end

    # 提供 trace_id 给 logger
    def logger
      @logger.define_singleton_method(:default_trace_id) { @trace_id } if @trace_id
      @logger
    end
  end
end
