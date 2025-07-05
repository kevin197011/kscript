# frozen_string_literal: true

require 'fileutils'

begin
  shell = ENV['SHELL']&.include?('zsh') ? 'zsh' : 'bash'
  script = `kscript completion #{shell}`
  case shell
  when 'zsh'
    comp_dir = File.expand_path('~/.zsh/completions')
    FileUtils.mkdir_p(comp_dir)
    File.write(File.join(comp_dir, '_kscript'), script)
  when 'bash'
    comp_dir = File.expand_path('~/.bash_completion.d')
    FileUtils.mkdir_p(comp_dir)
    File.write(File.join(comp_dir, 'kscript'), script)
  end
  puts "kscript: #{shell} completion deployed! Please restart your shell or source the completion file."
rescue StandardError => e
  warn "[kscript] Completion deploy failed: #{e.message}"
end
