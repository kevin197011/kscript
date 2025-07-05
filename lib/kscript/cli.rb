# frozen_string_literal: true

require 'kscript'
require 'io/console'
require 'kscript/banner'

module Kscript
  class CLI
    BIN_DIR = File.expand_path('../..', __dir__)
    PLUGINS_DIR = File.expand_path('plugins', __dir__)

    GLOBAL_FLAGS = %w[--log-level --trace-id --log].freeze

    def self.run!(argv = ARGV)
      puts Kscript::BANNER
      plugin_infos = Kscript::PluginLoader.plugin_infos
      plugin_infos.map { |info| info[:name].to_s.sub(/^kk_/, '') }.sort
      help = <<~HELP
          Usage: kscript [--log-level LEVEL] [--trace-id ID] <command> [args...]

          Global options:
            --log-level LEVEL   Set log level (debug, info, warn, error, fatal)
            --trace-id ID       Set trace id for all logs

          Available commands:
        #{plugin_infos.map { |info| "    #{info[:name].to_s.sub(/^kk_/, '').ljust(24)}#{info[:description] || ''}" }.join("\n")}

          Example:
            kscript --log-level debug port_scanner 192.168.1.1
            kscript --trace-id abc123 mac_sys_check

          Use 'kscript <command> --help' for command-specific help.
      HELP

      # 解析全局参数（先 shift 掉全局参数和命令名）
      args = argv.dup
      while args[0]&.start_with?('--')
        case args[0]
        when '--log-level', '--trace-id'
          args.shift
          args.shift
        when '--log'
          args.shift
        when '-h', '--help', 'help'
          puts help
          exit 0
        else
          break
        end
      end

      if args.empty? || (args[0] =~ /^(-h|--help|help)$/)
        puts help
        exit 0
      end

      cmd = args.shift
      plugin_args = args.reject { |arg| GLOBAL_FLAGS.any? { |flag| arg.start_with?(flag) } }

      def self.color(str, code)
        "\e[#{code}m#{str}\e[0m"
      end

      def self.cyan(str)
        color(str, 36)
      end

      def self.green(str)
        color(str, 32)
      end

      def self.gray(str)
        color(str, 90)
      end

      def self.bold(str)
        color(str, 1)
      end

      if cmd == 'list'
        puts "\n#{bold('Available commands:')}\n"
        # 按 group 分组
        grouped = plugin_infos.group_by { |info| info[:group] || 'other' }
        group_colors = %w[36 32 35 34 33 31 90 37] # cyan, green, magenta, blue, yellow, red, gray, white
        group_names = grouped.keys.sort
        group_names.each_with_index do |group, idx|
          color_code = group_colors[idx % group_colors.size]
          group_label = color("[#{group.capitalize}]", color_code)
          puts "#{group_label}"
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
            puts gray('    ' + ('-' * 60))
          end
          puts
        end
        exit 0
      end

      plugin_info = plugin_infos.find { |info| info[:name].to_s.sub(/^kk_/, '') == cmd }
      unless plugin_info
        warn "Unknown command: #{cmd}\n"
        puts help
        exit 1
      end
      klass = plugin_info[:class]
      unless klass
        warn "Plugin class not found for: #{cmd}\n"
        exit 1
      end
      begin
        instance = klass.new(*plugin_args)
        instance.run
      rescue ArgumentError => e
        warn "Argument error: #{e.message}"
        puts "Usage: kscript #{cmd} #{plugin_info[:arguments] || '[args...]'}"
        exit 1
      end
    end
  end
end
