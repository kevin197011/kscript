# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/port-scanner.rb | ruby

require 'socket'
require 'timeout'

# Class for scanning network ports with multi-threading support
class PortScanner
  attr_reader :host, :ports, :thread_count

  # Initialize the scanner with target host and port range
  # @param host [String] target host to scan
  # @param ports [Array<Integer>] list of ports to scan
  # @param thread_count [Integer] number of concurrent threads
  def initialize(host, ports, thread_count = 100)
    @host = host
    @ports = ports
    @thread_count = thread_count
  end

  # Execute port scanning using multiple threads
  def scan
    queue = Queue.new
    @ports.each { |port| queue.push(port) }

    threads = []
    @thread_count.times do
      threads << Thread.new do
        until queue.empty?
          port = queue.pop
          scan_port(port)
        end
      end
    end

    # Wait for all threads to complete
    threads.each(&:join)
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

if __FILE__ == $PROGRAM_NAME
  # Example usage
  target_host = '192.168.1.1'
  target_ports = (20..1024).to_a
  scanner = PortScanner.new(target_host, target_ports, 50)
  scanner.scan
end
