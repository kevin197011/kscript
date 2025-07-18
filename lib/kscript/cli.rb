# frozen_string_literal: true

require 'kscript'
require 'kscript/banner'

module Kscript
  class CLI < Thor
    Kscript::Config.load!

    class_option :log_level, type: :string, desc: 'Set log level (debug, info, warn, error, fatal)',
                             aliases: '--log-level'
    class_option :log, type: :boolean, desc: 'Enable structured log output', default: false

    def self.banner(command, _namespace = nil, _subcommand = false)
      "kscript #{command.usage}" if command.respond_to?(:usage)
    end

    desc 'version', 'Show kscript version'
    map %w[--version -v] => :version
    def version
      puts Kscript::BANNER
      puts color('─' * 80, 90)
      require 'kscript/version'
      puts "kscript version: #{Kscript::VERSION}"
    end

    desc 'list', 'List all available commands'
    def list
      puts Kscript::BANNER
      puts color('─' * 80, 90)
      plugin_infos = Kscript::PluginLoader.plugin_infos
      grouped = plugin_infos.group_by { |info| info[:group] || 'other' }
      group_colors = %w[36 32 35 34 33 31 90 37]
      group_names = grouped.keys.sort
      group_names.each_with_index do |group, idx|
        color_code = group_colors[idx % group_colors.size]
        group_label = color("[#{group.capitalize}]", color_code)
        puts group_label
        puts color('─' * 80, 90)
        grouped[group].each do |info|
          command = info[:name].to_s.sub(/^kk_/, '')
          desc = info[:description] || ''
          usage = info[:class].respond_to?(:usage) ? info[:class].usage : nil
          arguments = info[:class].respond_to?(:arguments) ? info[:class].arguments : nil
          author = info[:class].respond_to?(:author) ? info[:class].author : nil
          print "  #{green(command.ljust(16))}"
          print gray(desc)
          puts
          if usage && !usage.to_s.strip.empty?
            usage.to_s.split("\n").each_with_index do |line, idx|
              prefix = idx.zero? ? gray('    usage:') : gray('          ')
              puts "#{prefix} #{cyan(line.strip)}"
            end
          end
          puts gray("    args:  #{arguments}") if arguments && !arguments.to_s.strip.empty?
          puts gray("    by:    #{author}") if author && !author.to_s.strip.empty?
          puts gray("    #{'-' * 60}")
        end
        puts
      end
    end

    # 动态注册所有插件为子命令
    reserved = if defined?(Thor::Util::THOR_RESERVED_WORDS)
                 Thor::Util::THOR_RESERVED_WORDS.map(&:to_s)
               else
                 %w[shell help start version list exit invoke method_missing]
               end
    Kscript::PluginLoader.plugin_infos.each do |info|
      orig_command = info[:name].to_s.sub(/^kk_/, '')
      # shell -> sh
      command = orig_command == 'shell' ? 'sh' : orig_command
      command = "#{command}_cmd" if reserved.include?(command)
      klass = info[:class]
      desc command,
           (info[:description] || 'No description') + (reserved.include?(orig_command) ? " (original: #{orig_command})" : '')

      # 动态注册 option
      if klass.respond_to?(:arguments) && klass.arguments.is_a?(String)
        # 支持 '--file FILE --bucket BUCKET ...' 或 '<file> <bucket>'
        arg_str = klass.arguments
        arg_names = arg_str.scan(/--([a-zA-Z0-9_-]+)/).flatten
        # 兼容 <file> <bucket> 形式
        arg_names += arg_str.scan(/<([a-zA-Z0-9_-]+)>/).flatten
        arg_names.uniq.each do |param|
          next if %w[help version].include?(param)

          option param.to_sym, type: :string, desc: param
        end
      end

      define_method(command) do |*args|
        puts Kscript::BANNER
        puts color('─' * 80, 90)
        begin
          instance = klass.new(**options)
          instance.run(*args)
        rescue ArgumentError => e
          warn "Argument error: #{e.message}"
          puts "Usage: kscript #{command} #{klass.respond_to?(:arguments) ? klass.arguments : '[args...]'}"
          exit 1
        end
      end
    end

    desc 'env', 'Show current environment variables relevant to kscript'
    def env
      puts Kscript::BANNER
      puts color('─' * 80, 90)
      keys = ENV.keys.grep(/^(KSCRIPT_|AWS_|LOG$|SHELL$|HOME$)/)
      if keys.empty?
        puts gray('No relevant environment variables found.')
      else
        puts bold('Loaded environment variables:')
        keys.sort.each do |k|
          v = ENV.fetch(k, nil)
          puts green(k.ljust(28)) + gray('=') + cyan(v)
        end
      end
    end

    no_commands do
      def color(str, code)
        "\e[#{code}m#{str}\e[0m"
      end

      def cyan(str)
        color(str, 36)
      end

      def green(str)
        color(str, 32)
      end

      def gray(str)
        color(str, 90)
      end

      def bold(str)
        color(str, 1)
      end
    end

    # Thor help 美化
    def self.exit_on_failure?
      true
    end

    def help(*_args)
      puts Kscript::BANNER
      puts color('─' * 80, 90)
      # 只展示主命令（version、help、list）
      Kscript::PluginLoader.plugin_infos.select do |info|
        info[:name].to_s.sub(/^kk_/, '')
        false # 不输出插件命令
      end
      # 只输出主命令
      puts bold('Available commands:')
      puts green('  version'.ljust(16)) + gray('Show kscript version')
      puts green('  help'.ljust(16)) + gray('Describe available commands or one specific command')
      puts green('  list'.ljust(16)) + gray('List all available commands')
      puts
      puts bold('Options:')
      puts gray('  --log-level, [--log-level=LOG_LEVEL]            # Set log level (debug, info, warn, error, fatal)')
      puts gray('               [--log], [--no-log], [--skip-log]  # Enable structured log output')
      puts gray('  --log                        # Enable  structured log output')
      puts gray('                                                  # Default: false')
      puts
      puts gray("Use 'kscript list' to see all business subcommands.")
      nil
    end
  end
end
