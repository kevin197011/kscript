# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkVcsCleanerUtils < Kscript::Base
    DEFAULT_RETAIN_VERSIONS = 10

    attr_reader :source_path, :retain_count

    # Initialize the cleaner with path and retention settings
    # @param source_path [String] path to source code directory
    # @param retain_count [Integer] number of versions to keep
    def initialize(*args, **opts)
      super
      @source_path = args[0] || '/data/sources/*/**'
      @retain_count = args[1] || DEFAULT_RETAIN_VERSIONS
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
      "kscript vcs_cleaner ~/projects/src\nkscript vcs_cleaner . --exclude=vendor"
    end

    def self.group
      'project'
    end

    def self.author
      'kk'
    end

    def self.description
      'Clean old source code versions, keep N latest.'
    end

    private

    # Process a single application directory
    # @param app_path [String] path to application directory
    def process_application(app_path)
      versions = Dir.glob("#{app_path}/*")
      version_count = versions.length
      return if version_count <= @retain_count

      logger.kinfo("Processing #{app_path}", version_count: version_count, retain: @retain_count)
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
