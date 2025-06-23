# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/elastic-cert-fingerprint.rb | ruby

require 'openssl'

# Class for generating SHA256 fingerprint of Elasticsearch certificates
class ElasticCertFingerprint
  DEFAULT_CERT_PATH = 'elasticsearch.crt'

  attr_reader :cert_path

  # Initialize with certificate path
  # @param cert_path [String] path to the certificate file
  def initialize(cert_path = DEFAULT_CERT_PATH)
    @cert_path = cert_path
  end

  # Generate and display the certificate fingerprint
  def generate
    validate_certificate_file
    cert = load_certificate
    fingerprint = calculate_fingerprint(cert)
    display_fingerprint(fingerprint)
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit 1
  end

  private

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

ElasticCertFingerprint.new.generate if __FILE__ == $PROGRAM_NAME
