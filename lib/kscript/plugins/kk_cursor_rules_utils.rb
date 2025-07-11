# frozen_string_literal: true

# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'fileutils'
require 'kscript'

module Kscript
  class KkCursorRulesUtils < Base
    def initialize(*_args, **opts)
      super(**opts.merge(service: 'kk_cursor_rules'))
    end

    def run(*args, **_opts)
      with_error_handling do
        if args[0].to_s == 'deploy'
          deploy
        else
          logger.kwarn("Usage: #{self.class.usage}")
        end
      end
    end

    def deploy
      logger.kinfo('======= 🚀 Cursor Rules Deploy =======')
      logger.kinfo("📅 Date Time: #{Time.now}")
      logger.kinfo('')

      # Remove .cursor if exists
      if Dir.exist?('.cursor')
        logger.kinfo('Removing existing .cursor directory...')
        FileUtils.rm_rf('.cursor')
      end

      # Clone .cursor repo
      logger.kinfo('Cloning .cursor repo from github...')
      system_or_raise('git clone git@github.com:kevin197011/cursor.git .cursor')

      # Move Rakefile if not exists, else remove .cursor/Rakefile
      if !File.exist?('Rakefile') && File.exist?('.cursor/Rakefile')
        logger.kinfo('Moving .cursor/Rakefile to project root...')
        FileUtils.mv('.cursor/Rakefile', 'Rakefile')
      elsif File.exist?('.cursor/Rakefile')
        logger.kinfo('Removing .cursor/Rakefile (already present in root)...')
        FileUtils.rm_rf('.cursor/Rakefile')
      end

      # Move push.rb
      if File.exist?('.cursor/push.rb')
        logger.kinfo('Moving .cursor/push.rb to project root...')
        FileUtils.mv('.cursor/push.rb', 'push.rb')
      end

      # Move .rubocop.yml
      if File.exist?('.cursor/.rubocop.yml')
        logger.kinfo('Moving .cursor/.rubocop.yml to project root...')
        FileUtils.mv('.cursor/.rubocop.yml', '.rubocop.yml')
      end

      # Remove .cursor/.git if exists
      if File.exist?('.cursor/.git')
        logger.kinfo('Removing .cursor/.git directory...')
        FileUtils.rm_rf('.cursor/.git')
      end

      # Ensure .gitignore contains .cursor
      if File.exist?('.gitignore') && File.readlines('.gitignore').none? { |l| l.strip == '.cursor' }
        logger.kinfo('Adding .cursor to .gitignore...')
        File.open('.gitignore', 'a') { |f| f.puts '\n.cursor' }
      end

      logger.kinfo("\n✅ Cursor rules deploy completed!")
    end

    private

    def system_or_raise(cmd)
      logger.kinfo("Running: #{cmd}")
      success = system(cmd)
      raise "Command failed: #{cmd}" unless success
    end

    def with_error_handling
      yield
    rescue StandardError => e
      logger.kerror("[ERROR] #{e.class}: #{e.message}")
      exit(1)
    end

    # ==== CLI/Plugin Metadata ====
    def self.description
      'Cursor rules deploy helper: syncs .cursor repo and project rules.'
    end

    def self.arguments
      '[deploy]'
    end

    def self.usage
      'kscript cursor_rules deploy'
    end

    def self.group
      'devops'
    end

    def self.author
      'kk'
    end
  end
end
