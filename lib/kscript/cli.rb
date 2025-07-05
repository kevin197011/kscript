# frozen_string_literal: true

require 'kscript'
require 'kscript/banner'

module Kscript
  class CLI < Thor
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
      command = reserved.include?(command) ? "#{command}_cmd" : command
      klass = info[:class]
      desc command,
           (info[:description] || 'No description') + (reserved.include?(orig_command) ? " (original: #{orig_command})" : '')
      define_method(command) do |*args|
        puts Kscript::BANNER
        puts color('─' * 80, 90)
        begin
          instance = klass.new(*args)
          instance.run
        rescue ArgumentError => e
          warn "Argument error: #{e.message}"
          puts "Usage: kscript #{command} #{klass.respond_to?(:arguments) ? klass.arguments : '[args...]'}"
          exit 1
        end
      end
    end

    desc 'completion SHELL', 'Generate shell completion script (zsh or bash)'
    def completion(shell = 'zsh', capture: false)
      commands = %w[version help
                    list] + Kscript::PluginLoader.plugin_infos.map do |info|
                              cmd = info[:name].to_s.sub(/^kk_/, '')
                              cmd = 'sh' if cmd == 'shell'
                              cmd
                            end
      output = StringIO.new
      case shell
      when 'zsh'
        output.puts "#compdef kscript\n"
        output.puts '_kscript() {'
        output.puts '  local -a commands'
        output.puts '  commands=('
        commands.each do |cmd|
          output.puts "    '#{cmd}:kscript command'"
        end
        output.puts '  )'
        output.puts "  _describe 'command' commands"
        output.puts '}'
        output.puts 'compdef _kscript kscript'
      when 'bash'
        output.puts '_kscript_completions() {'
        output.puts "  COMPREPLY=($(compgen -W \"#{commands.join(' ')}\" -- \"${COMP_WORDS[1]}\"))"
        output.puts '}'
        output.puts 'complete -F _kscript_completions kscript'
      else
        output.puts "Unsupported shell: #{shell}. Only 'zsh' and 'bash' are supported."
        return capture ? output.string : (puts output.string)
      end
      capture ? output.string : (puts output.string)
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

# CLI 启动时自动检测并安装 shell 补全脚本
begin
  require_relative 'utils'
  Kscript::Utils::Config.ensure_completion_installed
rescue StandardError => e
  warn "[kscript] Shell completion auto-install failed: #{e.message}"
end
