# frozen_string_literal: true

require 'openssl'

cert_path = 'elasticsearch.crt'
cert = OpenSSL::X509::Certificate.new(File.read(cert_path))

fingerprint = OpenSSL::Digest::SHA256.hexdigest(cert.to_der)
formatted_fingerprint = fingerprint.scan(/../).join(':').upcase

puts formatted_fingerprint
