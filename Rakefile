# frozen_string_literal: true

# Copyright (c) 2024 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'time'

# Define default task
task default: %w[fmt push]

# Task to format the code with RuboCop
task :fmt do
  system 'rubocop -A' # Automatically fix offenses
end

# Task to commit and push changes to Git
task :push do
  system 'git add .' # Stage all changes
  system "git commit -m 'Update #{Time.now}.'" # Commit with a timestamp message
  system 'git pull' # Pull the latest changes from the repository
  system 'git push origin main' # Push changes to the main branch
end
