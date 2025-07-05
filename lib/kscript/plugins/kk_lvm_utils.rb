# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkLvmUtils < Base
    DEFAULT_CONFIG = {
      device: '/dev/sdb',
      volume_group: 'vg_data',
      logical_volume: 'lv_data',
      mount_point: '/data'
    }.freeze

    attr_reader :config

    # Initialize the LVM mounter with configuration
    # @param config [Hash] configuration options
    def initialize(*args, **opts)
      super(*args, **opts)
      @config = DEFAULT_CONFIG.merge(opts)
    end

    def run
      with_error_handling do
        setup
      end
    end

    def setup
      validate_device
      ensure_lvm_tools_installed
      setup_physical_volume
      setup_volume_group
      setup_logical_volume
      format_and_mount_volume
      update_fstab
      display_mount_status
    end

    def self.arguments
      '<device> <mount_point>'
    end

    def self.usage
      "kscript lvm /dev/sda2 /mnt/data\nkscript lvm /dev/vg0/lv_home /mnt/home"
    end

    def self.group
      'system'
    end

    def self.author
      'kk'
    end

    def self.description
      'Mount and manage Linux LVM volumes.'
    end

    private

    # Validate device existence
    def validate_device
      return if File.blockdev?(config[:device])

      fail_with_error("Device #{config[:device]} does not exist")
    end

    # Ensure LVM tools are installed
    def ensure_lvm_tools_installed
      return if system('which pvcreate > /dev/null 2>&1')

      logger.kinfo('🔧 Installing LVM tools...')
      case detect_os_family
      when 'redhat'
        run_command('yum install -y lvm2')
      when 'debian'
        run_command('apt update && apt install -y lvm2')
      else
        fail_with_error('Unsupported OS: cannot install lvm2')
      end
    end

    # Set up physical volume
    def setup_physical_volume
      return if physical_volume_exists?

      run_command("pvcreate #{config[:device]}")
    end

    # Set up volume group
    def setup_volume_group
      return if volume_group_exists?

      run_command("vgcreate #{config[:volume_group]} #{config[:device]}")
    end

    # Set up logical volume
    def setup_logical_volume
      return if logical_volume_exists?

      run_command("lvcreate -l 100%FREE -n #{config[:logical_volume]} #{config[:volume_group]}")
    end

    # Format and mount the volume
    def format_and_mount_volume
      format_volume unless volume_formatted?
      mount_volume unless volume_mounted?
    end

    # Update /etc/fstab for persistent mounting
    def update_fstab
      uuid = volume_uuid
      fstab_line = generate_fstab_entry(uuid)

      return if fstab_contains_uuid?(uuid)

      logger.kinfo('👉 Updating /etc/fstab...')
      File.open('/etc/fstab', 'a') { |f| f.puts(fstab_line) }
    end

    # Display current mount status
    def display_mount_status
      logger.kinfo("✅ Volume mounted successfully at #{config[:mount_point]}:")
      system("df -h #{config[:mount_point]}")
    end

    # Helper methods
    def detect_os_family
      content = File.read('/etc/os-release')
      if content =~ /ID_LIKE=.*rhel|centos|fedora/i || content =~ /ID=.*(rhel|centos|rocky|alma|fedora)/i
        'redhat'
      elsif content =~ /ID_LIKE=.*debian/i || content =~ /ID=.*(debian|ubuntu)/i
        'debian'
      else
        'unknown'
      end
    end

    def run_command(cmd)
      logger.kinfo("👉 Running: #{cmd}")
      system(cmd) || fail_with_error("Command failed: #{cmd}")
    end

    def fail_with_error(msg)
      logger.kerror("❌ #{msg}")
      exit 1
    end

    def physical_volume_exists?
      system("pvs #{config[:device]} > /dev/null 2>&1")
    end

    def volume_group_exists?
      system("vgs #{config[:volume_group]} > /dev/null 2>&1")
    end

    def logical_volume_exists?
      system("lvs /dev/#{config[:volume_group]}/#{config[:logical_volume]} > /dev/null 2>&1")
    end

    def volume_formatted?
      `blkid #{logical_volume_path}` =~ /TYPE="xfs"/
    end

    def volume_mounted?
      `mount | grep #{config[:mount_point]}`.include?(config[:mount_point])
    end

    def format_volume
      run_command("mkfs.xfs #{logical_volume_path}")
    end

    def mount_volume
      run_command("mkdir -p #{config[:mount_point]}")
      run_command("mount #{logical_volume_path} #{config[:mount_point]}")
    end

    def logical_volume_path
      "/dev/#{config[:volume_group]}/#{config[:logical_volume]}"
    end

    def volume_uuid
      uuid = `blkid #{logical_volume_path} | awk '{print $2}' | tr -d '"'`
      uuid.strip
    end

    def fstab_contains_uuid?(uuid)
      File.read('/etc/fstab').include?(uuid)
    end

    def generate_fstab_entry(_uuid)
      "#{logical_volume_path} #{config[:mount_point]} xfs defaults 0 0"
    end
  end
end
