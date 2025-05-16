#!/usr/bin/env ruby
# frozen_string_literal: true

# Function to detect OS family and version
def os_info
  content = File.read('/etc/os-release')

  family = if content =~ /ID_LIKE=.*rhel|centos|fedora/i || content =~ /ID=.*(rhel|centos|rocky|alma|fedora)/i
             'redhat'
           elsif content =~ /ID_LIKE=.*debian/i || content =~ /ID=.*(debian|ubuntu)/i
             'debian'
           else
             'unknown'
           end

  version_str = content[/VERSION_ID="?([\d.]+)"?/, 1] || '0'
  version_major = version_str.split('.').first.to_i

  { family: family, version: version_major }
end

# Function to execute shell commands
def run_command(cmd)
  puts "👉 Running: #{cmd}"
  result = system(cmd)
  return if result

  puts "❌ Command failed: #{cmd}"
  exit 1
end

os = os_info

# Update system packages
puts '👉 Updating system packages...'
if os[:family] == 'redhat'
  run_command('sudo yum update -y')
elsif os[:family] == 'debian'
  run_command('sudo apt update -y')
end

# Install EPEL repository (for RedHat systems)
if os[:family] == 'redhat'
  puts '👉 Installing EPEL repository...'
  run_command('sudo yum install -y epel-release')
end

# Install RPM Fusion repository (for FFmpeg in RedHat systems)
if os[:family] == 'redhat'
  puts "👉 Installing RPM Fusion repository for EL#{os[:version]}..."
  if os[:version] >= 7 && os[:version] <= 9
    run_command("sudo yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-#{os[:version]}.noarch.rpm")
  else
    puts "⚠️ RPM Fusion not officially supported for EL#{os[:version]}"
  end
end

# Install FFmpeg and dependencies
puts '👉 Installing FFmpeg...'
if os[:family] == 'redhat'
  run_command('sudo yum install -y ffmpeg ffmpeg-devel')
elsif os[:family] == 'debian'
  run_command('sudo apt install -y ffmpeg')
else
  puts '❌ Unsupported OS'
  exit 1
end

# Verify FFmpeg installation
puts '👉 Verifying FFmpeg installation...'
run_command('ffmpeg -version')

# Completion message
puts '✅ FFmpeg installation completed successfully!'
