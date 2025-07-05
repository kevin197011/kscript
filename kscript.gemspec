# frozen_string_literal: true

require_relative 'lib/kscript/version'

Gem::Specification.new do |spec|
  spec.name          = 'kscript'
  spec.version       = Kscript::VERSION
  spec.authors       = ['Kk']
  spec.email         = ['your.email@example.com']

  spec.summary       = 'A collection of Ruby utility scripts for sysadmin and development.'
  spec.description   = 'Kscript provides a set of handy Ruby scripts for system administration, development, and automation.'
  spec.homepage      = 'https://github.com/kevin197011/kscript'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

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
  spec.add_dependency 'http', '>= 4.0'

  # Development dependencies
  spec.add_development_dependency 'rubocop', '>= 1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
