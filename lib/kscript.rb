# frozen_string_literal: true

# Copyright (c) 2024 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module Kscript
  class Error < StandardError; end
  # Your code goes here...
end

Dir.glob(File.join(File.dirname(__FILE__), 'kscript/*.rb')).each do |r|
  require_relative "kscript/#{File.basename(r, '.rb')}"
end
