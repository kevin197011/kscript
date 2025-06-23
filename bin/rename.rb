# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/rename.rb | ruby

# Class for batch renaming files using regular expressions
class FileRenamer
  attr_reader :source_pattern, :target_pattern, :directory

  # Initialize the renamer with patterns
  # @param source_pattern [String] regex pattern to match source filenames
  # @param target_pattern [String] regex pattern for new filenames
  # @param directory [String] directory to process
  def initialize(source_pattern, target_pattern, directory = Dir.pwd)
    @source_pattern = source_pattern
    @target_pattern = target_pattern
    @directory = directory
  end

  # Execute the batch rename operation
  def rename
    Dir.entries(directory).each do |filename|
      process_file(filename)
    end
  end

  private

  # Process a single file for renaming
  # @param filename [String] name of file to process
  def process_file(filename)
    return unless should_process?(filename)

    new_name = generate_new_name(filename)
    return unless new_name

    rename_file(filename, new_name)
  end

  # Check if file should be processed
  # @param filename [String] name of file to check
  # @return [Boolean] true if file should be processed
  def should_process?(filename)
    File.file?(filename) && filename =~ /#{source_pattern}/
  end

  # Generate new filename using pattern
  # @param filename [String] original filename
  # @return [String] new filename
  def generate_new_name(filename)
    # Using eval is required here for complex regex replacements
    # rubocop:disable Security/Eval
    eval("\"#{filename}\"".gsub(/#{source_pattern}/, target_pattern))
    # rubocop:enable Security/Eval
  rescue StandardError => e
    puts "Error processing #{filename}: #{e.message}"
    nil
  end

  # Perform the actual file rename
  # @param old_name [String] current filename
  # @param new_name [String] new filename
  def rename_file(old_name, new_name)
    File.rename(old_name, new_name)
    puts "Renamed: #{old_name} -> #{new_name}"
  rescue StandardError => e
    puts "Error renaming #{old_name}: #{e.message}"
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 2
    puts "Usage: #{$PROGRAM_NAME} '<source_pattern>' '<target_pattern>'"
    exit 1
  end

  FileRenamer.new(ARGV[0], ARGV[1]).rename
end
