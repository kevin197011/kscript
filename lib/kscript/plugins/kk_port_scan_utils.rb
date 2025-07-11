# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkPortScanUtils < Kscript::Base
    attr_reader :host, :ports, :thread_count

    # Initialize the scanner with target host and port range
    # @param host [String] target host to scan
    # @param ports [Array<Integer>] list of ports to scan
    # @param thread_count [Integer] number of concurrent threads
    def initialize(*args, **opts)
      super
      @target = args[0]
      @ports = parse_ports(args[1] || (1..1024))
      @thread_count = (opts[:thread_count] || 50).to_i
    end

    def run(*args, **_opts)
      with_error_handling do
        # 支持命令行参数覆盖
        @target = args[0] if args[0]
        @ports = parse_ports(args[1]) if args[1]
        @thread_count = args[2].to_i if args[2]
        scan
      end
    end

    # Execute port scanning using multiple threads
    def scan
      msg = "Scanning #{@target} ports #{@ports} with concurrency=#{@thread_count}"
      logger.kinfo(msg)
      queue = Queue.new
      @ports.each { |port| queue << port }
      threads = []
      @thread_count.times do
        threads << Thread.new do
          until queue.empty?
            port = nil
            begin
              port = queue.pop(true)
            rescue ThreadError
              break
            end
            begin
              Socket.tcp(@target, port, connect_timeout: 0.5) do |_sock|
                logger.kinfo('Port open', port: port)
              end
            rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, SocketError
              # closed or filtered
            end
          end
        end
      end
      threads.each(&:join)
    end

    # 支持多种端口参数格式: 22,80,443 或 1..1024
    def parse_ports(ports)
      return ports.to_a if ports.is_a?(Range)

      if ports.is_a?(String)
        if ports.include?(',')
          ports.split(',').map(&:to_i)
        elsif ports.include?('..')
          begin
            eval(ports).to_a
          rescue StandardError
            (1..1024).to_a
          end
        else
          [ports.to_i]
        end
      elsif ports.is_a?(Array)
        ports.map(&:to_i)
      else
        (1..1024).to_a
      end
    end

    def self.description
      'Scan open ports on a target host.'
    end

    def self.arguments
      '<target_host> [ports] [thread_count]'
    end

    def self.usage
      "kscript port_scan 192.168.1.1\nkscript port_scan example.com 22,80,443 100\nkscript port_scan 192.168.1.1 1..1024 200"
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
        logger.kinfo("Port #{port} is open")
        s.close
      end
    rescue Timeout::Error
      # Connection timeout, ignore
    rescue StandardError => e
      logger.kerror("Error scanning port #{port}: #{e.message}")
    end
  end
end
