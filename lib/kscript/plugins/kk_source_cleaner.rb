# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/source-cleaner.rb | ruby

require 'kscript/base'
require 'fileutils'

module Kscript
  class KkSourceCleaner < Base
    DEFAULT_RETAIN_VERSIONS = 10

    attr_reader :source_path, :retain_count

    # Initialize the cleaner with path and retention settings
    # @param source_path [String] path to source code directory
    # @param retain_count [Integer] number of versions to keep
    def initialize(source_path = '/data/sources/*/**', retain_count = DEFAULT_RETAIN_VERSIONS, **opts)
      super(**opts.merge(service: 'kk_source_cleaner'))
      @source_path = source_path
      @retain_count = retain_count
    end

    def run
      with_error_handling do
        clean
      end
    end

    # Clean old versions while keeping the specified number of recent versions
    def clean
      Dir.glob(@source_path).each do |app_path|
        process_application(app_path)
      end
    end

    def self.arguments
      '[src_path]'
    end

    def self.usage
      "kscript source_cleaner ~/projects/src\nkscript source_cleaner . --exclude=vendor"
    end

    def self.group
      'project'
    end

    def self.author
      'kk'
    end

    private

    # Process a single application directory
    # @param app_path [String] path to application directory
    def process_application(app_path)
      versions = Dir.glob("#{app_path}/*")
      version_count = versions.length
      return if version_count <= @retain_count

      logger.info("Processing #{app_path}", version_count: version_count, retain: @retain_count)
      cleanup_old_versions(versions, version_count)
    end

    # Remove old versions of an application
    # @param versions [Array<String>] list of version directories
    # @param total_count [Integer] total number of versions
    def cleanup_old_versions(versions, total_count)
      sorted_versions = versions.sort_by { |dir| File.mtime(dir) }
      versions_to_delete = total_count - @retain_count
      sorted_versions[0, versions_to_delete].each do |dir|
        logger.info("Removing #{dir}", mtime: File.mtime(dir))
        FileUtils.rm_rf(dir)
      end
    end
  end
end

Kscript::KkSourceCleaner.new.run if __FILE__ == $PROGRAM_NAME
