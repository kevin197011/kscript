#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Create Rakefile for gem install hook
dir = File.dirname(__FILE__)
File.write(File.join(dir, 'Rakefile'), <<~RAKEFILE)
  task :default do
    # Add lib directory to load path
    lib_path = File.expand_path('../../lib', __FILE__)
    $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
    require 'kscript/post_install'
    Kscript::PostInstall.run
  end
RAKEFILE

# Run post-install script immediately for local development
def local_dev?
  ENV['GEM_ENV'] != 'production'
end

if local_dev?
  lib_path = File.expand_path('../lib', __dir__)
  $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
  require 'kscript/post_install'
  Kscript::PostInstall.run
end
