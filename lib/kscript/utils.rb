# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Kscript
  module Utils
    class Config
      DEFAULT_PATH = File.expand_path('~/.kscriptrc')

      def self.load
        @load ||= new
      end

      def initialize
        @data = File.exist?(DEFAULT_PATH) ? YAML.load_file(DEFAULT_PATH) : {}
      end

      def [](key)
        @data[key.to_s] || ENV["KSCRIPT_#{key.to_s.upcase}"]
      end

      def log_level
        self['log_level']
      end

      def trace_id
        self['trace_id']
      end

      # 自动检测并安装 shell 补全脚本
      def self.ensure_completion_installed(shell = nil)
        shell ||= ENV['SHELL']
        home = Dir.respond_to?(:home) ? Dir.home : ENV['HOME']
        return unless shell && home

        if shell.include?('zsh')
          completion_path = File.join(home, '.zsh/completions/_kscript')
          shell_type = 'zsh'
        elsif shell.include?('bash')
          completion_path = File.join(home, '.bash_completion.d/kscript')
          shell_type = 'bash'
        else
          return
        end

        # 已存在则跳过
        return if File.exist?(completion_path)

        # 生成补全脚本内容
        require_relative 'cli'
        script = case shell_type
                 when 'zsh' then Kscript::CLI.new.completion('zsh', capture: true)
                 when 'bash' then Kscript::CLI.new.completion('bash', capture: true)
                 end
        FileUtils.mkdir_p(File.dirname(completion_path))
        File.write(completion_path, script)
        puts "\e[32m[kscript] Shell completion installed to #{completion_path}\e[0m"
      rescue StandardError => e
        warn "[kscript] Failed to install shell completion: #{e.message}"
      end
    end
  end
end
