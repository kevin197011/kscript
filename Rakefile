# frozen_string_literal: true

# Copyright (c) 2024 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'digest'
require 'time'
require 'json'
# require 'standard/rake'

# Set application name and version
app_name = 'rate'
app_version = "v#{Time.new.strftime('%Y%m%d')}"

# Define default task
task default: %w[fmt push]

# Task to format the code with RuboCop
task :fmt do
  # Rake::Task['standard:fix'].invoke # Uncomment if using standard for fixing
  system 'rubocop -A' # Automatically fix offenses
end

# Task to commit and push changes to Git
task :push do
  system 'git add .' # Stage all changes
  system "git commit -m 'Update #{Time.now}.'" # Commit with a timestamp message
  system 'git pull' # Pull the latest changes from the repository
  system 'git push origin main' # Push changes to the main branch
end

# Task to package the application as a tar.gz file
task :package do
  # Clean up any previous tar.gz files
  Dir.glob("#{app_name}*tar.gz").each { |file| File.delete(file) }

  # Create a new tar.gz archive of the app
  system "tar zcf #{app_name}_#{app_version}.tar.gz #{app_name}"

  # Print success message
  puts "Update app tgz [#{app_name}_#{app_version}.tar.gz] succeed!"
end

# Task to generate and save application info (version and sha256)
task :info do
  # Generate SHA256 hash of the tar.gz file
  app_sha256 = Digest::SHA256.hexdigest File.read("#{app_name}_#{app_version}.tar.gz")

  # Prepare the info to be written into a JSON file
  app_info = { version: app_version, sha256: app_sha256 }

  # Write app info to JSON file
  File.open("#{app_name}.json", 'w') { |file| file.write(app_info.to_json) }
end

# Task to run packaging and info generation tasks
task :run do
  Rake::Task['package'].invoke # Invoke the 'package' task
  Rake::Task['info'].invoke    # Invoke the 'info' task
end
