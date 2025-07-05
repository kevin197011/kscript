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

  spec.files = Dir.chdir(__dir__) do
    files = `git ls-files -z`.split("\x0")
    files.select! do |f|
      f =~ %r{^(lib/|bin/kscript|README|LICENSE|Rakefile|Gemfile|kscript\.gemspec)}
    end
    files
  end
  spec.bindir        = 'bin'
  spec.executables   = ['kscript']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'http', '>= 4.0', '< 6.0'
  spec.add_dependency 'thor', '1.3.2'

  # Development dependencies
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # spec.extensions = ['ext/install.rb'] # 已移除，防止 native extension build 错误

  spec.post_install_message = <<~MSG
    [kscript] Shell completion is available!
    To enable shell completion for your shell, please run:
      ruby ext/install.rb
    Or see README for more details.
  MSG
end
