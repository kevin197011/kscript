# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript/base'
require 'win32/registry'
require 'fileutils'
require 'open-uri'

module Kscript
  class KkWindowsFontEnhancer < Base
    REGISTRY_PATH = 'Control Panel\\Desktop'
    MACTYPE_REGISTRY_PATH = 'Software\\MacType'
    MACTYPE_URL = 'https://github.com/snowie2000/mactype/releases/download/v1.2025.4.11/MacTypeInstaller_2025.4.11.exe'
    MACTYPE_INSTALLER = 'MacTypeSetup.exe'

    def initialize(*args, **opts)
      super
      @registry = Win32::Registry::HKEY_CURRENT_USER
      @auto_yes = args.include?('--yes') || opts[:yes]
    end

    def run(*_args, **_opts)
      with_error_handling do
        enhance
      end
    end

    def enhance
      logger.kinfo('=== Windows Font Enhancement Tool (Simulate macOS Effect) ===')
      configure_font_smoothing

      if confirm?('Do you want to install and configure MacType?')
        install_mactype
        configure_mactype
      end

      restart_explorer if confirm?('Do you want to restart Explorer to apply font effects?')

      logger.kinfo('[*] Font enhancement operations completed.')
      logger.kinfo('Please restart your computer for full effect (especially for MacType).')
    end

    def self.arguments
      '[--yes]'
    end

    def self.usage
      'kscript windows_font_enhancer [--yes]'
    end

    def self.group
      'windows'
    end

    def self.author
      'kk'
    end

    def self.description
      'Enhance Windows font rendering and optionally install MacType.'
    end

    private

    def configure_font_smoothing
      logger.kinfo('[*] Enabling Windows font smoothing...')
      @registry.open(REGISTRY_PATH, Win32::Registry::KEY_WRITE) do |reg|
        reg['FontSmoothing'] = '2'
        reg['FontSmoothingType'] = 2
        reg['FontSmoothingGamma'] = 1800
        reg['FontSmoothingOrientation'] = 1
      end
      logger.kinfo('[+] Font smoothing settings completed.')
    end

    def install_mactype
      logger.kinfo('[*] Downloading and installing MacType...')
      download_mactype
      install_mactype_silently
      logger.kinfo('[+] MacType installation completed.')
    end

    def download_mactype
      File.open(MACTYPE_INSTALLER, 'wb') do |saved_file|
        URI.open(MACTYPE_URL, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end

    def install_mactype_silently
      logger.kinfo('[*] Starting silent MacType installation...')
      system("start /wait #{MACTYPE_INSTALLER} /VERYSILENT /NORESTART")
    end

    def configure_mactype(scheme: 'Default')
      logger.kinfo('[*] Configuring MacType loading mode as registry...')
      begin
        @registry.create(MACTYPE_REGISTRY_PATH, Win32::Registry::KEY_WRITE) do |reg|
          reg['InstallMode'] = 'registry'
          reg['UserSetting'] = 1
          reg['UserScheme'] = scheme
        end
        logger.kinfo("[+] MacType registry configuration completed (Scheme: #{scheme})")
      rescue StandardError => e
        logger.kerror("[!] MacType configuration failed: #{e.message}")
      end
    end

    def restart_explorer
      logger.kinfo('[*] Restarting Explorer to apply font settings...')
      system('taskkill /f /im explorer.exe')
      sleep(1)
      system('start explorer.exe')
    end

    def confirm?(message)
      return true if @auto_yes

      logger.kinfo("\n#{message} (y/n)")
      print '> '
      $stdin.gets.strip.downcase == 'y'
    end
  end
end
