# frozen_string_literal: true

# Copyright (c) 2024 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Ruby 标准库
require 'json'
require 'logger'
require 'securerandom'
require 'yaml'
require 'fileutils'
require 'base64'
require 'rexml/document'
require 'net/http'
require 'timeout'
require 'socket'
require 'open3'
require 'openssl'

# 第三方 gem
require 'http'
require 'bcrypt'
require 'nokogiri'
require 'thor'
require 'aws-sdk-s3'
require 'dotenv'

require 'kscript/config'
require 'kscript/plugins'
require 'kscript/base'
require 'kscript/logger'
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

  # 统一插件加载，无论开发还是生产环境
  Kscript::PluginLoader.load_all

  class Error < StandardError; end
  # Your code goes here...
end
