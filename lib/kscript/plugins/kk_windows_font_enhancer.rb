# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/windows-font-enhancer.rb | ruby

require_relative '../base' unless defined?(Kscript::Base)
require 'win32/registry'
require 'fileutils'
require 'open-uri'

module Kscript
  class KkWindowsFontEnhancer < Base
    REGISTRY_PATH = 'Control Panel\\Desktop'
    MACTYPE_REGISTRY_PATH = 'Software\\MacType'
    MACTYPE_URL = 'https://github.com/snowie2000/mactype/releases/download/v1.2025.4.11/MacTypeInstaller_2025.4.11.exe'
    MACTYPE_INSTALLER = 'MacTypeSetup.exe'

    # Initialize the font enhancer
    def initialize
      @registry = Win32::Registry::HKEY_CURRENT_USER
    end

    # Run the font enhancement process
    def run
      with_error_handling do
        enhance
      end
    end

    def enhance
      display_welcome_message
      configure_font_smoothing

      if user_confirms?('Do you want to install and configure MacType?')
        install_mactype
        configure_mactype
      end

      restart_explorer if user_confirms?('Do you want to restart Explorer to apply font effects?')

      display_completion_message
    end

    def self.arguments
      '[subcommand] [options]'
    end

    def self.usage
      "kscript windows_font_enhancer enable\nkscript windows_font_enhancer disable"
    end

    def self.group
      'windows'
    end

    def self.author
      'kk'
    end

    private

    # Configure Windows font smoothing settings
    def configure_font_smoothing
      puts '[*] Enabling Windows font smoothing...'

      @registry.open(REGISTRY_PATH, Win32::Registry::KEY_WRITE) do |reg|
        apply_smoothing_settings(reg)
      end

      puts '[+] Font smoothing settings completed.'
    end

    # Apply font smoothing registry settings
    # @param reg [Win32::Registry] registry key to modify
    def apply_smoothing_settings(reg)
      reg['FontSmoothing'] = '2'               # Enable font smoothing
      reg['FontSmoothingType'] = 2             # 2 = ClearType (subpixel anti-aliasing)
      reg['FontSmoothingGamma'] = 1800         # Gamma value adjustment, higher = darker font
      reg['FontSmoothingOrientation'] = 1      # RGB subpixel orientation
    end

    # Install MacType font rendering tool
    def install_mactype
      puts '[*] Downloading and installing MacType...'
      download_mactype
      install_mactype_silently
      puts '[+] MacType installation completed.'
    end

    # Download MacType installer
    def download_mactype
      File.open(MACTYPE_INSTALLER, 'wb') do |saved_file|
        URI.open(MACTYPE_URL, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end

    # Run MacType installer silently
    def install_mactype_silently
      puts '[*] Starting silent MacType installation...'
      system("start /wait #{MACTYPE_INSTALLER} /VERYSILENT /NORESTART")
    end

    # Configure MacType settings
    # @param scheme [String] MacType scheme name
    def configure_mactype(scheme: 'Default')
      puts '[*] Configuring MacType loading mode as registry...'

      begin
        create_mactype_registry(scheme)
        puts "[+] MacType registry configuration completed (Scheme: #{scheme})"
      rescue StandardError => e
        puts "[!] MacType configuration failed: #{e.message}"
      end
    end

    # Create MacType registry entries
    # @param scheme [String] MacType scheme name
    def create_mactype_registry(scheme)
      @registry.create(MACTYPE_REGISTRY_PATH, Win32::Registry::KEY_WRITE) do |reg|
        reg['InstallMode'] = 'registry'    # Loading method: registry
        reg['UserSetting'] = 1
        reg['UserScheme'] = scheme         # Scheme name
      end
    end

    # Restart Windows Explorer
    def restart_explorer
      puts '[*] Restarting Explorer to apply font settings...'
      system('taskkill /f /im explorer.exe')
      sleep(1)
      system('start explorer.exe')
    end

    # Display welcome message
    def display_welcome_message
      puts '=== Windows Font Enhancement Tool (Simulate macOS Effect) ==='
    end

    # Display completion message
    def display_completion_message
      puts "\n[*] Font enhancement operations completed."
      puts 'Please restart your computer for full effect (especially for MacType).'
    end

    # Prompt user for confirmation
    # @param message [String] message to display
    # @return [Boolean] true if user confirms
    def user_confirms?(message)
      puts "\n#{message} (y/n)"
      print '> '
      gets.strip.downcase == 'y'
    end
  end
end

Kscript::KkWindowsFontEnhancer.new.run if __FILE__ == $PROGRAM_NAME
