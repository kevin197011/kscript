# frozen_string_literal: true

# Copyright (c) 2024 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'json'
require 'logger'
require 'securerandom'
require 'kscript/plugins'

require 'kscript/base'
require 'kscript/logger'
require 'kscript/utils'
require 'kscript/version'

module Kscript
  # fluentd 风格插件注册机制
  module Plugin
    @plugins = {}
    class << self
      attr_reader :plugins

      def register(name, klass)
        @plugins[name.to_sym] = klass
      end

      def [](name)
        @plugins[name.to_sym]
      end

      def all
        @plugins
      end
    end
  end

  # 自动加载 plugins 目录下所有插件（仅开发环境）
  if File.directory?(File.expand_path('kscript/plugins', __dir__))
    Dir[File.expand_path('kscript/plugins/*.rb', __dir__)].each do |plugin|
      require_relative plugin.sub("#{File.expand_path(__dir__)}/", '')
    end
  end

  Kscript::PluginLoader.load_all

  class Error < StandardError; end
  # Your code goes here...
end
