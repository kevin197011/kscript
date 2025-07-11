# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkWgAclUtils < Kscript::Base
    WIREGUARD_PORT = 51_821
    ALLOWED_IPS = %w[127.0.0.1].freeze

    def initialize(*args, **opts)
      super
    end

    def run
      with_error_handling do
        apply_rules
      end
    end

    def apply_rules
      add_whitelist_rules
      ensure_firewall_enabled
      display_current_rules
    end

    def self.arguments
      '[subcommand] [options]'
    end

    def self.usage
      "kscript wg_acl add --ip=10.0.0.2\nkscript wg_acl list"
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end

    def self.description
      'Manage WireGuard firewall ACL rules.'
    end

    private

    # Fetch current UFW rules
    # @return [Array<String>] list of current firewall rules
    def fetch_current_rules
      `sudo ufw status`.lines.map(&:strip)
    end

    # Check if a specific rule exists
    # @param ip [String] IP address to check
    # @param port [Integer] port number to check
    # @return [Boolean] true if rule exists
    def rule_exists?(ip, port)
      @current_rules.any? do |line|
        line.match?(/#{Regexp.escape(ip)}.*ALLOW.*#{port}/)
      end
    end

    # Add whitelist rules for allowed IPs
    def add_whitelist_rules
      ALLOWED_IPS.each do |ip|
        if rule_exists?(ip, WIREGUARD_PORT)
          logger.kinfo("✅ Rule exists: #{ip} → #{WIREGUARD_PORT}, skipping.")
        else
          logger.kinfo("👉 Adding rule: allow #{ip} to access port #{WIREGUARD_PORT}")
          system("sudo ufw allow from #{ip} to any port #{WIREGUARD_PORT}")
        end
      end
    end

    # Ensure UFW firewall is enabled
    def ensure_firewall_enabled
      ufw_status = `sudo ufw status`.strip
      if ufw_status.start_with?('Status: inactive')
        logger.kinfo('🔧 UFW is currently disabled, enabling...')
        system('sudo ufw enable')
      else
        logger.kinfo('✅ UFW is enabled.')
      end
    end

    # Display current firewall rules
    def display_current_rules
      logger.kinfo("\n📋 Current firewall rules:")
      system('sudo ufw status verbose')
      logger.kinfo("\n✅ Firewall rules update completed!")
    end
  end
end
