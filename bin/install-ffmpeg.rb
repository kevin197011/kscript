#!/usr/bin/env ruby

# Function to detect OS family
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

# Function to execute shell commands
def run_command(cmd)
  puts "👉 Running: #{cmd}"
  result = system(cmd)
  if !result
    puts "❌ Command failed: #{cmd}"
    exit 1
  end
end

# Update system packages
puts "👉 Updating system packages..."
run_command("sudo yum update -y") if os_family == "redhat"
run_command("sudo apt update -y") if os_family == "debian"

# Install EPEL repository (for RedHat systems)
if os_family == "redhat"
  puts "👉 Installing EPEL repository..."
  run_command("sudo yum install -y epel-release")
end

# Install RPM Fusion repository (for FFmpeg in RedHat systems)
if os_family == "redhat"
  puts "👉 Installing RPM Fusion repository..."
  run_command("sudo yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm")
end

# Install FFmpeg and dependencies
puts "👉 Installing FFmpeg..."
if os_family == "redhat"
  run_command("sudo yum install -y ffmpeg ffmpeg-devel")
elsif os_family == "debian"
  run_command("sudo apt install -y ffmpeg")
else
  puts "❌ Unsupported OS"
  exit 1
end

# Verify FFmpeg installation
puts "👉 Verifying FFmpeg installation..."
run_command("ffmpeg -version")

# Completion message
puts "✅ FFmpeg installation completed successfully!"
