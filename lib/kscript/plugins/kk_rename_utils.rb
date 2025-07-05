# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkRenameUtils < Base
    attr_reader :source_pattern, :target_pattern, :directory

    def initialize(*args, **opts)
      super(*args, **opts)
      @source_pattern = args[0]
      @target_pattern = args[1]
      @directory = args[2] || Dir.pwd
    end

    def run
      with_error_handling do
        rename
      end
    end

    def rename
      Dir.entries(@directory).each do |filename|
        process_file(filename)
      end
    end

    def self.arguments
      '<pattern> <replacement> [path]'
    end

    def self.usage
      "kscript rename foo bar ./src\nkscript rename 'test' 'prod' ~/projects"
    end

    def self.group
      'project'
    end

    def self.author
      'kk'
    end

    def self.description
      'Batch rename files by pattern.'
    end

    private

    def process_file(filename)
      return unless should_process?(filename)

      new_name = generate_new_name(filename)
      return unless new_name

      rename_file(filename, new_name)
    end

    def should_process?(filename)
      File.file?(File.join(@directory, filename)) && filename =~ /#{@source_pattern}/
    end

    def generate_new_name(filename)
      eval("\"#{filename}\"".gsub(/#{@source_pattern}/, @target_pattern))
    rescue StandardError => e
      logger.kerror("Error processing #{filename}: #{e.message}")
      nil
    end

    def rename_file(old_name, new_name)
      File.rename(File.join(@directory, old_name), File.join(@directory, new_name))
      logger.kinfo("Renamed: #{old_name} -> #{new_name}")
    rescue StandardError => e
      logger.kerror("Error renaming #{old_name}: #{e.message}")
    end
  end
end
