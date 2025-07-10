# frozen_string_literal: true

# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'time'
require 'rake'
require 'bundler/gem_tasks'

task default: %w[run]

task :push do
  system 'rubocop -A'
  system 'git add .'
  system "git commit -m \"Update #{Time.now}\""
  system 'git pull'
  system 'git push origin main'
end

task :run do
  system 'gem uninstall kscript -aIx'
  system 'gem build kscript.gemspec'
  system "gem install kscript-#{Kscript::VERSION}.gem"
  system 'rm -rf kscript-*.gem'
  system 'rm -rf pkg'
  # system 'kscript help'
  system 'kscript list'
  # system 'kscript version'
  # system 'kscript env'
end
