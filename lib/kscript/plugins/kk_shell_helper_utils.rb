# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkShellHelperUtils < Base
    CHT_SH_URL = 'https://cht.sh'

    attr_reader :command

    # Initialize with shell command to look up
    # @param command [String] command to get help for
    def initialize(*args, **opts)
      super
      @command = args.join(' ').strip
    end

    def run(*args, **_opts)
      command = args.join(' ').strip
      with_error_handling do
        if command.nil? || command.strip.empty?
          logger.kwarn("Usage: #{self.class.usage}")
        else
          fetch_help(command)
        end
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
    def fetch_help(command)
      response = make_request(command)
      response = response.first if response.is_a?(Array)
      logger.kinfo(response.body)
    rescue StandardError => e
      display_error(e)
    end

    def self.arguments
      '[subcommand] [args...]'
    end

    def self.usage
      "kscript shell_helper 'ls'\nkscript shell_helper 'echo hello'"
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

    # Make HTTP request to cheat.sh
    # @return [HTTPX::Response] response from cheat.sh
    def make_request(command)
      begin
        require 'httpx'
        require 'uri'
      rescue LoadError
        abort 'Missing dependency: httpx. Please run: gem install httpx'
      end
      HTTPX.with(
        headers: {
          'User-Agent' => 'curl/8.0.1',
          'Accept' => 'text/plain'
        }
      ).get("https://cheat.sh/#{URI.encode_www_form_component(command)}")
    end

    # Display error message
    # @param error [StandardError] error to display
    def display_error(error)
      logger.kerror("An error occurred: #{error.message}")
    end
  end
end
