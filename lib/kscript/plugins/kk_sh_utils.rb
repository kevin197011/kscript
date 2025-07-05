# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkShUtils < Base
    CHT_SH_URL = 'https://cht.sh'

    attr_reader :command

    # Initialize with shell command to look up
    # @param command [String] command to get help for
    def initialize(*args, **opts)
      super(*args, **opts)
      @command = args.first
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
      "kscript sh 'ls'\nkscript sh 'echo hello'"
    end

    def self.group
      'system'
    end

    def self.author
      'kk'
    end

    def self.description
      'Query sh command usage and cheatsheets.'
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
        text = extract_plain_text(response.body)
        logger.kinfo(text)
      else
        logger.kerror("Failed to retrieve data: #{response.status}")
      end
    end

    # 提取纯文本内容
    def extract_plain_text(body)
      body = body.to_s
      begin
        doc = Nokogiri::HTML(body)
        doc.search('script,style').remove
        text = doc.text.lines.map(&:strip)
        # 过滤掉包含广告/社交/Follow等内容的行
        text = text.reject { |line| line =~ /Follow @|twitter|github|sponsor|donate|chubin|^!function/ }
        text.reject!(&:empty?)
        # 去除顶部多余空白行，只保留正文
        text = text.drop_while(&:empty?)
        text.join("\n")
      rescue StandardError
        body.gsub(/\e\[[\d;]*m/, '').lines.reject do |line|
          line =~ /Follow @|twitter|github|sponsor|donate|chubin|^!function/
        end.drop_while { |line| line.strip.empty? }.join
      end
    end

    # Display error message
    # @param error [StandardError] error to display
    def display_error(error)
      logger.kerror("An error occurred: #{error.message}")
    end
  end
end
