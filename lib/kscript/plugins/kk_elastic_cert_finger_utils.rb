# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# require 'kscript'

module Kscript
  class KkElasticCertFingerUtils < Kscript::Base
    DEFAULT_CERT_PATH = 'elasticsearch.crt'

    attr_reader :cert_path

    # Initialize with certificate path
    # @param cert_path [String] path to the certificate file
    def initialize(*args, **opts)
      super
      @cert_path = opts[:cert_path] || self.class::DEFAULT_CERT_PATH
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
      "kscript elastic_cert_finger <cert_file>\nkscript elastic_cert_finger ./ca.crt"
    end

    def self.group
      'elastic'
    end

    def self.author
      'kk'
    end

    def self.description
      'Generate Elasticsearch certificate SHA256 fingerprint.'
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
      logger.kinfo(fingerprint)
    end
  end
end
