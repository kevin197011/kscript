#!/usr/bin/env ruby
# frozen_string_literal: true

require 'http'

# class
class ShellHelper
  attr_accessor :cmd

  def initialize(cmd)
    @cmd = cmd
  end

  def run
    url = "https://cht.sh/#{@cmd}"

    begin
      response = HTTP.get(url)
      if response.status.success?
        puts response.body
      else
        puts "Failed to retrieve data: #{response.status}"
      end
    rescue HTTP::Error => e
      puts "An error occurred: #{e.message}"
    end
  end
end

ShellHelper.new(ARGV[0]).run if __FILE__ == $PROGRAM_NAME
