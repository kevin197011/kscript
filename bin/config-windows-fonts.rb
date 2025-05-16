# frozen_string_literal: true

require 'win32/registry'
require 'fileutils'
require 'open-uri'

# === Configure system registry to enable font smoothing (simulate macOS grayscale anti-aliasing style) ===
def enable_font_smoothing
  puts '[*] Enabling Windows font smoothing...'

  Win32::Registry::HKEY_CURRENT_USER.open('Control Panel\\Desktop', Win32::Registry::KEY_WRITE) do |reg|
    reg['FontSmoothing'] = '2'               # Enable font smoothing
    reg['FontSmoothingType'] = 2             # 2 = ClearType (subpixel anti-aliasing)
    reg['FontSmoothingGamma'] = 1800         # Gamma value adjustment, higher = darker font
    reg['FontSmoothingOrientation'] = 1      # RGB subpixel orientation
  end

  puts '[+] Font smoothing settings completed.'
end

# === Silently install MacType (font rendering alternative tool) ===
def install_mactype
  puts '[*] Downloading and installing MacType...'

  url = 'https://github.com/snowie2000/mactype/releases/download/v1.2025.4.11/MacTypeInstaller_2025.4.11.exe'
  exe_file = 'MacTypeSetup.exe'

  # Download
  File.open(exe_file, 'wb') do |saved_file|
    URI.open(url, 'rb') do |read_file|
      saved_file.write(read_file.read)
    end
  end

  puts '[*] Starting silent MacType installation...'
  system("start /wait #{exe_file} /VERYSILENT /NORESTART")

  puts '[+] MacType installation completed.'
end

# === Configure MacType loading mode ===
def configure_mactype(scheme: 'Default')
  puts '[*] Configuring MacType loading mode as registry...'

  begin
    key_path = 'Software\\MacType'
    Win32::Registry::HKEY_CURRENT_USER.create(key_path, Win32::Registry::KEY_WRITE) do |reg|
      reg['InstallMode'] = 'registry'    # Loading method: registry
      reg['UserSetting'] = 1
      reg['UserScheme'] = scheme         # Scheme name
    end
    puts "[+] MacType registry configuration completed (Scheme: #{scheme})"
  rescue StandardError => e
    puts "[!] MacType configuration failed: #{e.message}"
  end
end

# === Restart Explorer to apply settings ===
def restart_explorer
  puts '[*] Restarting Explorer to apply font settings...'
  system('taskkill /f /im explorer.exe')
  sleep(1)
  system('start explorer.exe')
end

# === Main execution flow ===
def main
  puts '=== Windows Font Enhancement Tool (Simulate macOS Effect) ==='

  enable_font_smoothing

  puts "\nDo you want to install and configure MacType? (y/n)"
  print '> '
  if gets.strip.downcase == 'y'
    install_mactype
    configure_mactype
  end

  puts "\nDo you want to restart Explorer to apply font effects? (y/n)"
  print '> '
  restart_explorer if gets.strip.downcase == 'y'

  puts "\n[*] Font enhancement operations completed. Please restart your computer for full effect (especially for MacType)."
end

main
