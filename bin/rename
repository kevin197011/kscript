#!/usr/bin/env ruby
# frozen_string_literal: true

# This script batch renames files in the current directory based on the given regular expressions.
# Usage example: `ruby rename.rb '_\.(.*)' '$1'`
# This would remove underscores from the file names.

class Rename
  attr_accessor :src_re, :dst_re, :current_dir

  # Initialize with the source regex (src_re) and destination regex (dst_re).
  # current_dir defaults to the current working directory.
  def initialize(src_re, dst_re)
    @src_re = src_re
    @dst_re = dst_re
    @current_dir = Dir.pwd
  end

  # Run the renaming process.
  def run
    # Iterate through all files in the current directory.
    Dir.entries(@current_dir).each do |file|
      # Skip if it's not a file (directories and special entries).
      next unless File.file?(file)

      # Rename the file if it matches the source regex (src_re).
      next unless file =~ /#{@src_re}/

      new_name = eval(@dst_re) # Evaluate the destination regex.
      File.rename(file, new_name) # Rename the file.
      puts "Renamed: #{file} -> #{new_name}" # Output the change.
    end
  end
end

# Run the script if invoked from the command line.
if __FILE__ == $PROGRAM_NAME
  # Ensure there are exactly two arguments: source and destination regex.
  if ARGV.length != 2
    puts "Usage: ruby #{$PROGRAM_NAME} '<src_re>' '<dst_re>'"
    exit 1
  end

  # Instantiate the Rename class and run the renaming process.
  Rename.new(ARGV[0], ARGV[1]).run
end
