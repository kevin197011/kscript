# frozen_string_literal: true

require 'fiddle'
require 'fiddle/import'

module User32
  extend Fiddle::Importer
  dlload 'user32'

  # 函数定义
  extern 'int SetCursorPos(int, int)'
  extern 'int GetCursorPos(void*)' # 接收指针参数
end

puts '开始鼠标定时晃动（Fiddle实现），按Ctrl+C停止'

begin
  loop do
    # 获取当前鼠标位置（使用 Fiddle 分配内存）
    pos = Fiddle::Pointer.malloc(8) # 两个long=8字节
    User32.GetCursorPos(pos)
    x, y = pos[0, 8].unpack('ll') # 解包为两个long

    # 轻微晃动（向右→向左→回原位）
    User32.SetCursorPos(x + 10, y)
    sleep(0.05)
    User32.SetCursorPos(x - 10, y)
    sleep(0.05)
    User32.SetCursorPos(x, y)

    puts "#{Time.now.strftime('%H:%M:%S')} | 鼠标已晃动"

    # 等待5分钟（300秒）
    sleep(300)
  end
rescue Interrupt
  puts "\n已停止"
end
