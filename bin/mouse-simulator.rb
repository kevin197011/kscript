# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/mouse-simulator.rb | ruby

require 'fiddle'
require 'fiddle/import'

# Module for Windows User32.dll function imports
module User32
  extend Fiddle::Importer
  dlload 'user32'

  # Import required Windows API functions
  extern 'int SetCursorPos(int, int)'
  extern 'int GetCursorPos(void*)'
end

# Class for simulating mouse movement to prevent system idle
class MouseSimulator
  MOVEMENT_INTERVAL = 300 # seconds
  MOVEMENT_DISTANCE = 10 # pixels

  def initialize
    @running = true
  end

  # Start the mouse movement simulation
  def start
    puts 'Starting mouse movement simulation (Press Ctrl+C to stop)'

    while @running
      move_mouse
      sleep MOVEMENT_INTERVAL
    end
  rescue Interrupt
    puts "\nMouse simulation stopped"
  end

  private

  # Perform a single mouse movement cycle
  def move_mouse
    current_pos = get_current_position
    return unless current_pos

    x, y = current_pos
    simulate_movement(x, y)
    log_movement
  end

  # Get current mouse cursor position
  # @return [Array<Integer>] x and y coordinates
  def get_current_position
    pos = Fiddle::Pointer.malloc(8) # Two longs = 8 bytes
    User32.GetCursorPos(pos)
    pos[0, 8].unpack('ll')
  end

  # Simulate mouse movement pattern
  # @param x [Integer] current x coordinate
  # @param y [Integer] current y coordinate
  def simulate_movement(x, y)
    User32.SetCursorPos(x + MOVEMENT_DISTANCE, y)
    sleep(0.05)
    User32.SetCursorPos(x - MOVEMENT_DISTANCE, y)
    sleep(0.05)
    User32.SetCursorPos(x, y)
  end

  # Log movement timestamp
  def log_movement
    puts "#{Time.now.strftime('%H:%M:%S')} | Mouse movement completed"
  end
end

MouseSimulator.new.start if __FILE__ == $PROGRAM_NAME
