# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/port-scanner.rb | ruby

require_relative '../base' unless defined?(Kscript::Base)
require 'socket'
require 'timeout'

module Kscript
  class KkPortScanner < Base
    attr_reader :host, :ports, :thread_count

    # Initialize the scanner with target host and port range
    # @param host [String] target host to scan
    # @param ports [Array<Integer>] list of ports to scan
    # @param thread_count [Integer] number of concurrent threads
    def initialize(target = nil, ports = (1..1024), **opts)
      super(**opts.merge(service: 'kk_port_scanner'))
      @target = target
      @ports = ports.is_a?(Range) ? ports : (1..1024)
    end

    def run
      with_error_handling do
        scan
      end
    end

    # Execute port scanning using multiple threads
    def scan
      logger.info("Scanning #{@target} ports #{@ports}")
      @ports.each do |port|
        Socket.tcp(@target, port, connect_timeout: 0.5) do |_sock|
          logger.info('Port open', port: port)
          puts "Port #{port} is open"
        end
      rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, SocketError
        # closed or filtered
      end
    end

    def self.description
      'Scan open ports on a target host.'
    end

    def self.arguments
      '<target_host>'
    end

    def self.usage
      "kscript port_scanner 192.168.1.1\nkscript port_scanner example.com --ports=22,80,443"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end

    private

    # Scan a single port for open status
    # @param port [Integer] port number to scan
    def scan_port(port)
      Timeout.timeout(1) do # Set connection timeout to 1 second
        s = TCPSocket.new(@host, port)
        puts " [+] Port #{port} is open"
        s.close
      end
    rescue Timeout::Error
      # Connection timeout, ignore
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ETIMEDOUT
      # Handle connection refused, host unreachable or connection timeout errors
    rescue StandardError => e
      puts " [-] Error scanning port #{port}: #{e.message}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Usage: #{$PROGRAM_NAME} <target_host>"
    exit 1
  end
  Kscript::KkPortScanner.new(ARGV[0]).run
end
