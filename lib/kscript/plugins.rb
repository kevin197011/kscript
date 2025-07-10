# frozen_string_literal: true

module Kscript
  module PluginLoader
    PLUGIN_DIR = File.expand_path('plugins', __dir__)

    def self.load_all
      Dir.glob(File.join(PLUGIN_DIR, 'kk_*.rb')).each do |file|
        # 解析出类名
        basename = File.basename(file, '.rb')
        class_name = basename.split('_').map(&:capitalize).join
        # 只在未定义时 require
        require file unless Kscript.const_defined?(class_name, false)
      end
    end

    # 返回所有已注册插件的元信息
    def self.plugin_infos
      Kscript::Plugin.all.map do |name, klass|
        {
          name: name,
          class: klass,
          description: klass.respond_to?(:description) ? klass.description : nil,
          arguments: klass.respond_to?(:arguments) ? klass.arguments : nil,
          usage: klass.respond_to?(:usage) ? klass.usage : nil,
          group: klass.respond_to?(:group) ? klass.group : nil,
          author: klass.respond_to?(:author) ? klass.author : nil
        }
      end
    end
  end
end
