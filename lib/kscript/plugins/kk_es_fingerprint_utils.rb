# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/elastic-cert-fingerprint.rb | ruby

require 'kscript'
require 'kscript/base'

module Kscript
  class KkEsFingerprintUtils < Base
    DEFAULT_CERT_PATH = 'elasticsearch.crt'

    attr_reader :cert_path

    # Initialize with certificate path
    # @param cert_path [String] path to the certificate file
    def initialize(cert_path = DEFAULT_CERT_PATH)
      @cert_path = cert_path
    end

    def run
      with_error_handling do
        generate
      end
    end

    def self.arguments
      '<cert_file>'
    end

    def self.usage
      "kscript elastic_cert_fingerprint /etc/elasticsearch/certs/http_ca.crt\nkscript elastic_cert_fingerprint ./ca.crt"
    end

    def self.group
      'elastic'
    end

    def self.author
      'kk'
    end

    private

    # Generate and display the certificate fingerprint
    def generate
      validate_certificate_file
      cert = load_certificate
      fingerprint = calculate_fingerprint(cert)
      display_fingerprint(fingerprint)
    end

    # Validate certificate file existence
    def validate_certificate_file
      return if File.exist?(cert_path)

      raise "Certificate file not found: #{cert_path}"
    end

    # Load X509 certificate from file
    # @return [OpenSSL::X509::Certificate] loaded certificate
    def load_certificate
      OpenSSL::X509::Certificate.new(File.read(cert_path))
    end

    # Calculate SHA256 fingerprint
    # @param cert [OpenSSL::X509::Certificate] certificate to process
    # @return [String] formatted fingerprint
    def calculate_fingerprint(cert)
      raw_fingerprint = OpenSSL::Digest::SHA256.hexdigest(cert.to_der)
      format_fingerprint(raw_fingerprint)
    end

    # Format fingerprint with colons
    # @param fingerprint [String] raw fingerprint
    # @return [String] formatted fingerprint
    def format_fingerprint(fingerprint)
      fingerprint.scan(/../).join(':').upcase
    end

    # Display the formatted fingerprint
    # @param fingerprint [String] formatted fingerprint to display
    def display_fingerprint(fingerprint)
      puts fingerprint
    end
  end
end
