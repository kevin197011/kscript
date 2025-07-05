# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/project-scanner.rb | ruby

require 'json'

module Kscript
  class KkProjectScanner < Base
    def initialize(src_path = nil, **opts)
      super(**opts.merge(service: 'kk_project_scanner'))
      @src_path = src_path || File.expand_path('~/projects/src')
    end

    def run
      with_error_handling do
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
      "kscript project_scanner ~/projects/src\nkscript project_scanner /opt --type=go"
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

      logger.error("Source directory not found: #{@src_path}")
      exit 1
    end

    def scan_projects
      projects = []
      Dir.glob(File.join(@src_path, '*')).sort.each do |path|
        next unless File.directory?(path)
        next unless git_project?(path)

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
      logger.info('Scanned projects', count: projects.size)
      puts JSON.pretty_generate(projects)
    end
  end
end

Kscript::KkProjectScanner.new.run if __FILE__ == $PROGRAM_NAME
