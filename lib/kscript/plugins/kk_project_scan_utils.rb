# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkProjectScanUtils < Kscript::Base
    def initialize(*args, **opts)
      super
    end

    def run(*args, **_opts)
      with_error_handling do
        @src_path = args[0] || @src_path || Dir.pwd
        scan_and_display
      end
    end

    def scan_and_display
      ensure_directory_exists
      projects = scan_projects
      display_projects(projects)
    end

    def self.description
      'Scan and list all git projects in a directory.'
    end

    def self.arguments
      '[src_path]'
    end

    def self.usage
      "kscript project_scan ~/projects/src\nkscript project_scan /opt --type=go"
    end

    def self.group
      'project'
    end

    def self.author
      'kk'
    end

    private

    def ensure_directory_exists
      return if Dir.exist?(@src_path)

      logger.kerror("Source directory not found: #{@src_path}")
      exit 1
    end

    def scan_projects
      projects = []
      Dir.glob(File.join(@src_path, '*')).each do |path|
        next unless File.directory?(path)

        # next unless git_project?(path)

        project_name = File.basename(path)
        projects << create_project_entry(project_name, path)
      end
      projects
    end

    def git_project?(path)
      File.directory?(File.join(path, '.git'))
    end

    def create_project_entry(name, path)
      {
        name: name,
        rootPath: path,
        paths: [],
        tags: [],
        enabled: true
      }
    end

    def display_projects(projects)
      logger.kinfo('Scanned projects', count: projects.size)
      logger.kinfo('Projects', projects: JSON.pretty_generate(projects))
    end
  end
end
