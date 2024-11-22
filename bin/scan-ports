#!/usr/bin/env ruby

# frozen_string_literal: true

require 'socket'
require 'timeout'

# PortScanner类封装端口扫描逻辑
class PortScanner
  def initialize(host, ports, thread_count = 100)
    @host = host
    @ports = ports
    @thread_count = thread_count
  end

  # 执行端口扫描
  def scan_ports
    queue = Queue.new
    @ports.each { |port| queue.push(port) }

    threads = []
    @thread_count.times do
      threads << Thread.new do
        until queue.empty?
          port = queue.pop
          scan(port)
        end
      end
    end

    # 等待所有线程执行完成
    threads.each(&:join)
  end

  private

  # 扫描单个端口
  def scan(port)
    Timeout.timeout(1) do # 设置连接超时为1秒
      s = TCPSocket.new(@host, port)
      puts " [+] Port #{port} is open"
      s.close
    end
  rescue Timeout::Error
    # 连接超时，忽略
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ETIMEDOUT
    # 处理连接拒绝、主机不可达或连接超时的错误
    # 不输出任何信息，或可以选择调试信息
  rescue StandardError => e
    # 捕获其它异常并打印
    puts " [-] Error on port #{port}: #{e.message}"
  end
end

# 示例用法
if __FILE__ == $PROGRAM_NAME
  host = '192.168.1.1' # 替换为目标主机
  ports = (20..1024).to_a # 扫描20到1024端口
  scanner = PortScanner.new(host, ports, 50) # 使用50个线程进行并发扫描
  scanner.scan_ports
end
