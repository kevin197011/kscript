# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkShellUtils < Base
    CHT_SH_URL = 'https://cht.sh'

    attr_reader :command

    # Initialize with shell command to look up
    # @param command [String] command to get help for
    def initialize(command = nil, *_args, **_opts)
      @command = command
    end

    def run
      with_error_handling do
        help
      end
    end

    def help
      if command
        fetch_help
      else
        logger.kinfo("Usage: #{$PROGRAM_NAME} <command>")
        exit 1
      end
    end

    # Fetch and display command documentation
    def fetch_help
      response = make_request
      display_result(response)
    rescue HTTP::Error => e
      display_error(e)
    end

    def self.arguments
      '[subcommand] [args...]'
    end

    def self.usage
      "kscript shell run 'ls -al'\nkscript shell exec 'echo hello'"
    end

    def self.group
      'system'
    end

    def self.author
      'kk'
    end

    def self.description
      'Query shell command usage and cheatsheets.'
    end

    private

    # Make HTTP request to cht.sh
    # @return [HTTP::Response] response from cht.sh
    def make_request
      HTTP.get("#{CHT_SH_URL}/#{command}")
    end

    # Display command documentation
    # @param response [HTTP::Response] response from cht.sh
    def display_result(response)
      if response.status.success?
        logger.kinfo(response.body)
      else
        logger.kerror("Failed to retrieve data: #{response.status}")
      end
    end

    # Display error message
    # @param error [StandardError] error to display
    def display_error(error)
      logger.kerror("An error occurred: #{error.message}")
    end
  end
end
