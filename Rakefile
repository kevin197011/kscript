# frozen_string_literal: true

# Copyright (c) 2024 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'digest'
require 'time'
require 'json'
# require 'standard/rake'

# Setting update app name
app_name = 'rate'

app_version = "v#{Time.new.strftime('%Y%m%d')}"

task default: %w[fmt push]

task :fmt do
  # Rake::Task['standard:fix'].invoke
  system 'rubocop -A'
end

task :push do
  system 'git add .'
  system "git commit -m 'Update #{Time.now}.'"
  system 'git pull'
  system 'git push origin main'
end

task :package do
  Dir.glob("#{app_name}*tar.gz").each { |file| File.delete(file) }
  system "tar zcf #{app_name}_#{app_version}.tar.gz #{app_name}"
  Rails.logger.debug { "Update app tgz [#{app_name}_#{app_version}.tar.gz] succeed!" }
end

task :info do
  app_sha256 = Digest::SHA256.hexdigest File.read "#{app_name}_#{app_version}.tar.gz"
  app_info = { version: app_version, sha256: app_sha256 }
  File.open("#{app_name}.json", 'w') { |file| file.write(app_info.to_json) }
end

task :run do
  Rake::Task['package'].invoke
  Rake::Task['info'].invoke
end
