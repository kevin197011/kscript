#!/usr/bin/env ruby

# frozen_string_literal: true

require 'fileutils'

# data path
code_path = '/data/sources/*/**'
# keep versions
retain_versions = 10

Dir.glob(code_path).each do |app|
  versions = Dir.glob("#{app}/*").length
  next if versions <= retain_versions

  puts "#{app} versions: #{versions}, delete #{versions - retain_versions}"

  sorted_dirs = Dir.glob("#{app}/*").sort_by { |dir| File.mtime(dir) }
  sorted_dirs[0, versions - retain_versions].each do |d|
    puts "  #{d} => #{File.mtime(d)}"
    FileUtils.rm_rf(d)
  end
end
