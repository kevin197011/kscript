# frozen_string_literal: true

require 'kscript'

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
      @logger.set_human_output(human_output?)
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

    # 自动注册所有 Kscript::Base 的子类为插件
    def self.inherited(subclass)
      name = subclass.name.split('::').last
      if name.start_with?('Kk') && name.end_with?('Utils')
        cmd = name[2..-6] # 去掉 Kk 和 Utils
        # 转 snake_case
        cmd = cmd.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '').sub(/_$/, '')
        Kscript::Plugin.register(cmd.to_sym, subclass)
      end
      super if defined?(super)
    end

    # 判断是否为人性化输出模式（无 --log/--log-level 参数且 ENV['LOG'] 未设置）
    def human_output?
      !(ARGV.include?('--log') || ARGV.include?('--log-level') || ENV['LOG'])
    end
  end
end
