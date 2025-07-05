# frozen_string_literal: true

require 'yaml'

module Kscript
  module Utils
    class Config
      DEFAULT_PATH = File.expand_path('~/.kscriptrc')

      def self.load
        @load ||= new
      end

      def initialize
        @data = File.exist?(DEFAULT_PATH) ? YAML.load_file(DEFAULT_PATH) : {}
      end

      def [](key)
        @data[key.to_s] || ENV["KSCRIPT_#{key.to_s.upcase}"]
      end

      def log_level
        self['log_level']
      end

      def trace_id
        self['trace_id']
      end
    end
  end
end
