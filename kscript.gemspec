# frozen_string_literal: true

require_relative 'lib/kscript/version'

Gem::Specification.new do |spec|
  spec.name          = 'kscript'
  spec.version       = Kscript::VERSION
  spec.authors       = ['Kk']
  spec.email         = ['kevin197011@outlook.com']

  spec.summary       = 'A collection of Ruby utility scripts for sysadmin and development.'
  spec.description   = 'Kscript provides a set of handy Ruby scripts for system administration, development, and automation.'
  spec.homepage      = 'https://github.com/kevin197011/kscript'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  # Metadata
  spec.metadata = {
    'homepage_uri' => 'https://github.com/kevin197011/kscript',
    'source_code_uri' => 'https://github.com/kevin197011/kscript.git',
    'changelog_uri' => 'https://github.com/kevin197011/kscript/blob/main/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  # Files
  spec.files = Dir.glob(%w[
                          lib/**/*
                          exe/*
                          ext/**/*
                          *.md
                          *.txt
                        ]).reject { |f| File.directory?(f) }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/mkrf_conf.rb']

  # Runtime dependencies
  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'httpx'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'parallel'
  spec.add_dependency 'rake'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-prompt'
  # Ruby 标准库和系统自带的无需声明

  # Development dependencies
  spec.add_development_dependency 'rubocop'

  # Post install message
  spec.post_install_message = <<~MESSAGE
    🎉 Thanks for installing kscript!

    Shell completion and config example will be configured automatically.
    You may need to restart your shell or run:
      - For Bash: source ~/.bashrc
      - For Zsh: source ~/.zshrc

    Edit ~/.kscript/.env to customize your environment variables.

    Happy scripting! 🚀
  MESSAGE
end
