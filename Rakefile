# frozen_string_literal: true

# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'time'
require 'rake'
require 'bundler/gem_tasks'

task default: %w[push]

task :push do
  system <<-SHELL
    rubocop -A
    git update-index --chmod=+x push
    git add .
    git commit -m "Update #{Time.now}"
    git pull
    git push origin main
  SHELL
end

# 其他自定义任务可在此添加
task :dev do
  sh <<-SHELL
    gem uninstall kscript -aIx
    gem build kscript.gemspec
    gem install kscript-*.gem
    kscript help
    kscript list
    kscript version
  SHELL
end
