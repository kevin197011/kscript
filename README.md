# kscript

A collection of Ruby utility scripts for various system administration and development tasks.

## Installation

```bash
git clone https://github.com/kevin197011/kscript.git
cd kscript
bundle install
```

## Usage

Most scripts can be executed directly via curl:

```bash
curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/SCRIPT_NAME.rb | ruby
```

## Available Scripts

### System Tools
- `mac-top-usage.rb` - Display top CPU and memory usage processes on macOS
- `port-scanner.rb` - Multi-threaded port scanner
- `mouse-simulator.rb` - Simulate mouse movement to prevent system idle
- `source-cleaner.rb` - Clean up old source code versions
- `ffmpeg-installer.rb` - FFmpeg installation script for Linux systems

### Network Tools
- `ip-api.rb` - Query IP geolocation information (supports auto-detecting public IP)
- `apnic-ip-range.rb` - Fetch IP ranges from APNIC database
- `wireguard-acl.rb` - Configure WireGuard firewall access control
- `wireguard-password.rb` - Generate WireGuard password hashes

### Development Tools
- `shell-helper.rb` - Quick shell command reference tool
- `rename.rb` - Batch rename files using regular expressions
- `jenkins-job-manager.rb` - Manage Jenkins jobs (export/import)
- `kibana-utils.rb` - Kibana management utilities

### Windows Specific
- `windows-font-enhancer.rb` - Enhance Windows font rendering (macOS-like)

### Infrastructure Tools
- `elastic-cert-fingerprint.rb` - Generate Elasticsearch certificate fingerprints
- `lvm-mounter.rb` - LVM volume creation and mounting utility

## Examples

1. Query IP geolocation:
```bash
# Query specific IP
curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/ip-api.rb | ruby 8.8.8.8

# Query your public IP
curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/ip-api.rb | ruby
```

2. View system resource usage:
```bash
curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/mac-top-usage.rb | ruby
```

3. Scan ports:
```bash
curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/port-scanner.rb | ruby
```

## Dependencies

Required gems:
```ruby
gem 'http'
gem 'rubocop'
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

