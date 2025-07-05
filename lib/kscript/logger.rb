# frozen_string_literal: true

module Kscript
  # Structured logger for all scripts
  class Logger
    LEVELS = %i[debug info warn error fatal unknown].freeze

    # 极客风格终端输出
    COLORS = {
      info: "\e[32m", # green
      warn: "\e[33m", # yellow
      error: "\e[31m", # red
      debug: "\e[90m", # gray
      reset: "\e[0m"
    }.freeze

    def initialize(service: 'kscript', level: :info, out: $stdout, human_output: nil)
      @service = service
      @logger = ::Logger.new(out)
      @logger.level = ::Logger.const_get(level.to_s.upcase)
      @human_output = human_output
    end

    # 允许外部设置输出模式
    def set_human_output(val)
      @human_output = val
    end

    def human_output?
      @human_output == true
    end

    def log_mode?
      @human_output == false
    end

    LEVELS.each do |level|
      define_method(level) do |message, context = {}|
        if human_output?
          puts "[#{level.to_s.upcase}] #{message} #{context.map { |k, v| "#{k}=#{v}" }.join(' ')}".strip
        else
          log(level, message, context)
        end
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

    # 极客风格终端输出
    def klog(level, message, context = {})
      if human_output?
        puts "[#{level.to_s.upcase}] #{message} #{context.map { |k, v| "#{k}=#{v}" }.join(' ')}".strip
      else
        ts = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        lvl = level.to_s.upcase
        svc = @service || 'kscript'
        trace = context[:trace_id] || (respond_to?(:default_trace_id) ? default_trace_id : nil) || '-'
        color = COLORS[level] || COLORS[:info]
        ctx_str = context.reject { |k, _| k == :trace_id }.map { |k, v| "#{k}=#{v}" }.join(' ')
        line = "[#{ts}] [#{lvl}] [#{svc}] [#{trace}] #{message}"
        line += " | #{ctx_str}" unless ctx_str.empty?
        $stdout.puts "#{color}#{line}#{COLORS[:reset]}"
      end
    end

    # 便捷方法
    def kinfo(msg, ctx = {})
      klog(:info, msg, ctx)
    end

    def kwarn(msg, ctx = {})
      klog(:warn, msg, ctx)
    end

    def kerror(msg, ctx = {})
      klog(:error, msg, ctx)
    end

    def kdebug(msg, ctx = {})
      klog(:debug, msg, ctx)
    end
  end
end
