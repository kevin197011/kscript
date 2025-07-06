# frozen_string_literal: true

module Kscript
  class PostInstall
    class << self
      def run
        setup_env_example
        setup_shell_completion
      end

      private

      def setup_env_example
        env_dir = File.expand_path('~/.kscript')
        env_file = File.join(env_dir, '.env')
        return if File.exist?(env_file)

        FileUtils.mkdir_p(env_dir)
        File.open(env_file, 'w') do |f|
          f.puts "# kscript config: all variables are optional, remove '#' to enable"
          f.puts '# AWS S3 upload config'
          f.puts '# AWS_BUCKET=my-bucket            # S3 bucket name'
          f.puts '# AWS_REGION=ap-northeast-1      # AWS region, e.g. ap-northeast-1'
          f.puts '# AWS_ACCESS_KEY_ID=xxx         # AWS access key id'
          f.puts '# AWS_SECRET_ACCESS_KEY=yyy     # AWS secret access key'
          f.puts
          f.puts '# Shell environment (auto detected, usually not needed)'
          f.puts '# SHELL=/bin/zsh                # User shell'
          f.puts '# HOME=/Users/yourname          # User home directory'
          f.puts
          f.puts '# Logging config'
          f.puts '# KSCRIPT_LOG_LEVEL=info        # Log level: debug, info, warn, error, fatal'
          f.puts '# LOG=1                         # Enable structured log output'
        end
        puts '[kscript] ~/.kscript/.env example created. Edit and uncomment as needed.'
      end

      def setup_shell_completion
        setup_bash_completion
        setup_zsh_completion
      end

      def setup_bash_completion
        return unless File.exist?(bashrc_path)

        completion_path = find_completion_file('kscript.bash')
        return if completion_path.nil?

        source_line = "source \"#{completion_path}\""
        content = File.read(bashrc_path)
        if content.match?(/source.*kscript\.bash/)
          # Update existing config
          new_content = content.gsub(/source.*kscript\.bash.*$/, source_line)
          File.write(bashrc_path, new_content)
        else
          # Append new config
          File.open(bashrc_path, 'a') do |f|
            f.puts "\n# Kscript completion"
            f.puts source_line
          end
        end
        puts "✅ Bash completion configured in #{bashrc_path}"
      rescue StandardError => e
        puts "⚠️ Failed to configure Bash completion: #{e.message}"
      end

      def setup_zsh_completion
        return unless File.exist?(zshrc_path)

        completion_path = find_completion_file('kscript.zsh')
        return if completion_path.nil?

        source_lines = [
          "source \"#{completion_path}\"",
          'autoload -Uz compinit && compinit'
        ]
        content = File.read(zshrc_path)
        if content.match?(/source.*kscript\.zsh/)
          # Update existing config
          new_content = content.gsub(/source.*kscript\.zsh.*$/, source_lines[0])
          File.write(zshrc_path, new_content)
        else
          # Append new config
          File.open(zshrc_path, 'a') do |f|
            f.puts "\n# Kscript completion"
            source_lines.each { |line| f.puts line unless content.include?(line) }
          end
        end
        puts "✅ Zsh completion configured in #{zshrc_path}"
      rescue StandardError => e
        puts "⚠️ Failed to configure Zsh completion: #{e.message}"
      end

      def find_completion_file(filename)
        # Try all possible paths
        paths = [
          # Dev path
          File.expand_path("../completions/#{filename}", __FILE__),
          # Gem install paths
          *Gem.path.map { |path| File.join(path, "gems/kscript-*/lib/completions/#{filename}") },
          # System paths
          "/usr/local/share/kscript/completions/#{filename}",
          "/usr/share/kscript/completions/#{filename}"
        ]
        paths.each do |path|
          if path.include?('*')
            matches = Dir.glob(path)
            return matches.first if matches.any?
          elsif File.exist?(path)
            return path
          end
        end
        puts "⚠️ Could not find completion file: #{filename}"
        puts 'Searched paths:'
        paths.each { |path| puts " - #{path}" }
        nil
      end

      def bashrc_path
        File.join(Dir.home, '.bashrc')
      end

      def zshrc_path
        File.join(Dir.home, '.zshrc')
      end
    end
  end
end
