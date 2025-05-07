#!/usr/bin/env ruby

DEVICE = "/dev/sdb"
VG_NAME = "vg_data"
LV_NAME = "lv_data"
MOUNT_POINT = "/data"

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
  content = File.read("/etc/os-release")
  if content =~ /ID_LIKE=.*rhel|centos|fedora/i || content =~ /ID=.*(rhel|centos|rocky|alma|fedora)/i
    "redhat"
  elsif content =~ /ID_LIKE=.*debian/i || content =~ /ID=.*(debian|ubuntu)/i
    "debian"
  else
    "unknown"
  end
end

# Detect OS and install lvm2 if not found
unless system("which pvcreate > /dev/null 2>&1")
  puts "🔧 lvm2 not found, installing..."

  case os_family
  when "redhat"
    run("yum install -y lvm2")
  when "debian"
    run("apt update && apt install -y lvm2")
  else
    fail_exit("Unsupported OS: cannot install lvm2")
  end
end

# Check if the device exists
fail_exit("Device #{DEVICE} does not exist") unless File.blockdev?(DEVICE)

# Create physical volume, volume group, and logical volume
run("pvcreate #{DEVICE}")
run("vgcreate #{VG_NAME} #{DEVICE}")
run("lvcreate -l 100%FREE -n #{LV_NAME} #{VG_NAME}")

# Format the logical volume with XFS
run("mkfs.xfs /dev/#{VG_NAME}/#{LV_NAME}")

# Create the mount point directory
run("mkdir -p #{MOUNT_POINT}")

# Mount the logical volume
run("mount /dev/#{VG_NAME}/#{LV_NAME} #{MOUNT_POINT}")

# Get UUID and append to /etc/fstab for persistent mount
uuid = `blkid -s UUID -o value /dev/#{VG_NAME}/#{LV_NAME}`.strip
fail_exit("Failed to get UUID") if uuid.empty?

puts "👉 Writing to /etc/fstab..."
fstab_line = "UUID=#{uuid}  #{MOUNT_POINT}  xfs  defaults  0  0\n"
File.open("/etc/fstab", "a") { |f| f.write(fstab_line) }

# Show disk usage
puts "✅ Mounted successfully at #{MOUNT_POINT}:"
system("df -h #{MOUNT_POINT}")
