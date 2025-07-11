# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkFfmpegInstallUtils < Kscript::Base
    def initialize(*args, **opts)
      super
    end

    def run
      with_error_handling do
        install
      end
    end

    def install
      logger.kinfo('FFmpeg installer executed.')
    end

    def self.arguments
      '[version]'
    end

    def self.usage
      "kscript ffmpeg_install 6.0\nkscript ffmpeg_install latest"
    end

    def self.group
      'media'
    end

    def self.author
      'kk'
    end

    def self.description
      'Install and verify FFmpeg on Linux.'
    end

    private

    # Detect OS family and version
    # @return [Hash] OS family and version information
    def detect_os_info
      content = File.read('/etc/os-release')
      {
        family: detect_os_family(content),
        version: detect_os_version(content)
      }
    end

    # Detect OS family from os-release content
    # @param content [String] contents of os-release file
    # @return [String] OS family name
    def detect_os_family(content)
      if content =~ /ID_LIKE=.*rhel|centos|fedora/i || content =~ /ID=.*(rhel|centos|rocky|alma|fedora)/i
        'redhat'
      elsif content =~ /ID_LIKE=.*debian/i || content =~ /ID=.*(debian|ubuntu)/i
        'debian'
      else
        'unknown'
      end
    end

    # Detect OS version from os-release content
    # @param content [String] contents of os-release file
    # @return [Integer] major version number
    def detect_os_version(content)
      version_str = content[/VERSION_ID="?([\d.]+)"?/, 1] || '0'
      version_str.split('.').first.to_i
    end

    # Update system package lists
    def update_system
      logger.kinfo('👉 Updating system packages...')
      case @os_info[:family]
      when 'redhat'
        run_command('sudo yum update -y')
      when 'debian'
        run_command('sudo apt update -y')
      end
    end

    # Install prerequisite repositories
    def install_prerequisites
      return unless @os_info[:family] == 'redhat'

      install_epel
      install_rpm_fusion if @os_info[:version].between?(7, 9)
    end

    # Install EPEL repository
    def install_epel
      logger.kinfo('👉 Installing EPEL repository...')
      run_command('sudo yum install -y epel-release')
    end

    # Install RPM Fusion repository
    def install_rpm_fusion
      logger.kinfo("👉 Installing RPM Fusion repository for EL#{@os_info[:version]}...")
      run_command("sudo yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-#{@os_info[:version]}.noarch.rpm")
    end

    # Install FFmpeg packages
    def install_ffmpeg
      logger.kinfo('👉 Installing FFmpeg...')
      case @os_info[:family]
      when 'redhat'
        run_command('sudo yum install -y ffmpeg ffmpeg-devel')
      when 'debian'
        run_command('sudo apt install -y ffmpeg')
      else
        fail_with_error('Unsupported OS')
      end
    end

    # Verify FFmpeg installation
    def verify_installation
      logger.kinfo('👉 Verifying FFmpeg installation...')
      run_command('ffmpeg -version')
      logger.kinfo('✅ FFmpeg installation completed successfully!')
    end

    # Execute shell command
    # @param cmd [String] command to execute
    def run_command(cmd)
      logger.kinfo("👉 Running: #{cmd}")
      system(cmd) || fail_with_error("Command failed: #{cmd}")
    end

    # Display error and exit
    # @param msg [String] error message
    def fail_with_error(msg)
      logger.kerror("❌ #{msg}")
      exit 1
    end
  end
end
