# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/lvm-mounter.rb | ruby

# Class for managing LVM volume creation and mounting
class LvmMounter
  DEFAULT_CONFIG = {
    device: '/dev/sdb',
    volume_group: 'vg_data',
    logical_volume: 'lv_data',
    mount_point: '/data'
  }.freeze

  attr_reader :config

  # Initialize the LVM mounter with configuration
  # @param config [Hash] configuration options
  def initialize(config = {})
    @config = DEFAULT_CONFIG.merge(config)
  end

  # Set up LVM and mount the volume
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

  private

  # Validate device existence
  def validate_device
    return if File.blockdev?(config[:device])

    fail_with_error("Device #{config[:device]} does not exist")
  end

  # Ensure LVM tools are installed
  def ensure_lvm_tools_installed
    return if system('which pvcreate > /dev/null 2>&1')

    puts '🔧 Installing LVM tools...'
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

    puts '👉 Updating /etc/fstab...'
    File.open('/etc/fstab', 'a') { |f| f.puts(fstab_line) }
  end

  # Display current mount status
  def display_mount_status
    puts "✅ Volume mounted successfully at #{config[:mount_point]}:"
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
    puts "👉 Running: #{cmd}"
    system(cmd) || fail_with_error("Command failed: #{cmd}")
  end

  def fail_with_error(msg)
    puts "❌ #{msg}"
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
    uuid = `blkid -s UUID -o value #{logical_volume_path}`.strip
    fail_with_error('Failed to get UUID') if uuid.empty?
    uuid
  end

  def generate_fstab_entry(uuid)
    "UUID=#{uuid}  #{config[:mount_point]}  xfs  defaults  0  0"
  end

  def fstab_contains_uuid?(uuid)
    File.read('/etc/fstab').include?(uuid)
  end
end

LvmMounter.new.setup if __FILE__ == $PROGRAM_NAME
