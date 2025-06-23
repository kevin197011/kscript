# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/project-scanner.rb | ruby

require 'json'

# Class for scanning projects directory and generating VS Code project configuration
class ProjectScanner
  attr_reader :src_path

  # Initialize with source directory
  # @param src_path [String] path to source directory
  def initialize(src_path = nil)
    @src_path = src_path || File.expand_path('~/projects/src')
  end

  # Scan directory and display configuration
  def scan_and_display
    ensure_directory_exists
    projects = scan_projects
    display_projects(projects)
  end

  private

  # Ensure source directory exists
  def ensure_directory_exists
    return if Dir.exist?(@src_path)

    puts "❌ Source directory not found: #{@src_path}"
    exit 1
  end

  # Scan for Git projects in source directory
  # @return [Array<Hash>] list of project configurations
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

  # Check if directory is a Git repository
  # @param path [String] directory path to check
  # @return [Boolean] true if directory is a Git repository
  def git_project?(path)
    File.directory?(File.join(path, '.git'))
  end

  # Create project configuration entry
  # @param name [String] project name
  # @param path [String] project path
  # @return [Hash] project configuration entry
  def create_project_entry(name, path)
    {
      name: name,
      rootPath: path,
      paths: [],
      tags: [],
      enabled: true
    }
  end

  # Display projects in copyable format
  # @param projects [Array<Hash>] list of project configurations
  def display_projects(projects)
    puts JSON.pretty_generate(projects)
  end
end

if __FILE__ == $PROGRAM_NAME
  scanner = ProjectScanner.new
  scanner.scan_and_display
end
