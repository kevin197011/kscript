# frozen_string_literal: true

require 'kscript'

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/rename.rb | ruby

module Kscript
  class KkRenameUtils < Base
    attr_reader :source_pattern, :target_pattern, :directory

    def initialize(source_pattern = nil, target_pattern = nil, directory = Dir.pwd, **opts)
      super(**opts.merge(service: 'kk_rename'))
      @source_pattern = source_pattern
      @target_pattern = target_pattern
      @directory = directory
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
      logger.error("Error processing #{filename}: #{e.message}")
      nil
    end

    def rename_file(old_name, new_name)
      File.rename(File.join(@directory, old_name), File.join(@directory, new_name))
      logger.info("Renamed: #{old_name} -> #{new_name}")
    rescue StandardError => e
      logger.error("Error renaming #{old_name}: #{e.message}")
    end
  end
end
