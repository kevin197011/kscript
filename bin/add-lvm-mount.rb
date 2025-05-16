#!/usr/bin/env ruby
# frozen_string_literal: true

DEVICE = '/dev/sdb'
VG_NAME = 'vg_data'
LV_NAME = 'lv_data'
MOUNT_POINT = '/data'

def fail_exit(msg)
  puts "❌ #{msg}"
  exit 1
end

def run(cmd)
  puts "👉 Running: #{cmd}"
  success = system(cmd)
  fail_exit("Command failed: #{cmd}") unless success
end

def os_family
  content = File.read('/etc/os-release')
  if content =~ /ID_LIKE=.*rhel|centos|fedora/i || content =~ /ID=.*(rhel|centos|rocky|alma|fedora)/i
    'redhat'
  elsif content =~ /ID_LIKE=.*debian/i || content =~ /ID=.*(debian|ubuntu)/i
    'debian'
  else
    'unknown'
  end
end

# Detect OS and install lvm2 if not found
unless system('which pvcreate > /dev/null 2>&1')
  puts '🔧 lvm2 not found, installing...'

  case os_family
  when 'redhat'
    run('yum install -y lvm2')
  when 'debian'
    run('apt update && apt install -y lvm2')
  else
    fail_exit('Unsupported OS: cannot install lvm2')
  end
end

# Check if the device exists
fail_exit("Device #{DEVICE} does not exist") unless File.blockdev?(DEVICE)

# Check if device is already a physical volume
if `pvs #{DEVICE} 2>/dev/null`.include?(DEVICE)
  puts "⚠️ Device #{DEVICE} is already a physical volume. Skipping pvcreate."
else
  run("pvcreate #{DEVICE}")
end

# Check if volume group exists
if `vgs #{VG_NAME} 2>/dev/null`.include?(VG_NAME)
  puts "⚠️ Volume group #{VG_NAME} already exists. Skipping vgcreate."
else
  run("vgcreate #{VG_NAME} #{DEVICE}")
end

# Check if logical volume exists
if `lvs /dev/#{VG_NAME}/#{LV_NAME} 2>/dev/null`.include?(LV_NAME)
  puts "⚠️ Logical volume #{LV_NAME} already exists. Skipping lvcreate."
else
  run("lvcreate -l 100%FREE -n #{LV_NAME} #{VG_NAME}")
end

LV_PATH = "/dev/#{VG_NAME}/#{LV_NAME}".freeze

# Check if LV already has a filesystem
if `blkid #{LV_PATH}` =~ /TYPE="xfs"/
  puts '⚠️ Logical volume already formatted. Skipping mkfs.'
else
  run("mkfs.xfs #{LV_PATH}")
end

# Create the mount point directory
run("mkdir -p #{MOUNT_POINT}")

# Check if already mounted
if `mount | grep #{MOUNT_POINT}`.include?(MOUNT_POINT)
  puts "⚠️ #{MOUNT_POINT} is already mounted. Skipping mount."
else
  run("mount #{LV_PATH} #{MOUNT_POINT}")
end

# Get UUID and ensure fstab entry exists
uuid = `blkid -s UUID -o value #{LV_PATH}`.strip
fail_exit('Failed to get UUID') if uuid.empty?

fstab_line = "UUID=#{uuid}  #{MOUNT_POINT}  xfs  defaults  0  0"

if File.read('/etc/fstab').include?(uuid)
  puts '⚠️ UUID already in /etc/fstab. Skipping fstab update.'
else
  puts '👉 Writing to /etc/fstab...'
  File.open('/etc/fstab', 'a') { |f| f.puts(fstab_line) }
end

# Show disk usage
puts "✅ Mounted successfully at #{MOUNT_POINT}:"
system("df -h #{MOUNT_POINT}")
