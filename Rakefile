# frozen_string_literal: true

# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'time'
require 'rake'
require 'bundler/gem_tasks'
require 'fileutils'

task default: %w[run]

task :update_completions do
  require_relative 'lib/kscript'
  commands = Kscript::Plugin.all.keys.map { |k| k.to_s.sub(/^kk_/, '') }.sort

  bash_content = <<~BASH
    # kscript bash completion
    # Auto-generated command completion for kscript CLI

    _kscript_completions() {
        local cur
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"

        # Main command list as array
        local opts=(
            #{commands.join(' ')}
        )

        if [[ ${COMP_CWORD} == 1 ]]; then
            COMPREPLY=( $(compgen -W "${opts[*]}" -- "${cur}") )
            return 0
        fi
    }

    complete -F _kscript_completions kscript
  BASH

  zsh_content = <<~ZSH
    #compdef kscript
    _kscript() {
      local -a commands
      commands=(
        #{commands.map { |c| "'#{c}:kscript command'" }.join("\n    ")}
      )
      _describe 'command' commands
    }
    compdef _kscript kscript
  ZSH

  File.write('lib/kscript/completions/kscript.bash', bash_content)
  File.write('lib/kscript/completions/kscript.zsh', zsh_content)
  puts 'Shell completions updated.'
end

task :push do
  Rake::Task['update_completions'].invoke
  system 'rubocop -A'
  system 'git add .'
  system "git commit -m \"Update #{Time.now}\""
  system 'git pull'
  system 'git push origin main'
end

task :run do
  Rake::Task['update_completions'].invoke
  system 'gem uninstall kscript -aIx'
  system 'gem build kscript.gemspec'
  system "gem install kscript-#{Kscript::VERSION}.gem"
  system 'rm -rf kscript-*.gem'
  system 'rm -rf pkg'
  # system 'kscript help'
  system 'kscript list'
  # system 'kscript version'
  # system 'kscript env'
end
