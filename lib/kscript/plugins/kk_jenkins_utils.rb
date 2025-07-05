# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'
require 'http'
require 'base64'
require 'rexml/document'
require 'json'
require 'fileutils'
require 'kscript/base'

module Kscript
  class KkJenkinsUtils < Base
    def run
      with_error_handling do
        logger.kinfo('Jenkins job manager executed.')
      end
    end

    def initialize(jenkins_url, user, password)
      @jenkins_url = jenkins_url
      @user = user
      @password = password
      @auth_header = "Basic #{Base64.strict_encode64("#{@user}:#{@password}")}"
      @output = $stdout
      @output.sync = true
    end

    def export_all_jobs
      FileUtils.mkdir_p('jobs')

      job_names = get_all_job_names
      job_names.each do |job_name|
        config_xml = export_job(job_name)
        if config_xml
          File.write("jobs/#{job_name}.xml", config_xml)
          logger.kinfo("Exported job: #{job_name}")
        end
      end
    end

    def import_job_from_file(job_name)
      file_path = "jobs/#{job_name}.xml"
      if File.exist?(file_path)
        config_xml = File.read(file_path)
        import_or_update_job(job_name, config_xml)
      else
        logger.kerror("Job file #{file_path} does not exist!")
      end
    end

    def import_all_jobs_from_files
      job_files = Dir.glob('jobs/*.xml')
      job_files.each do |file_path|
        job_name = File.basename(file_path, '.xml')
        logger.kinfo("Importing or updating job: #{job_name}")
        config_xml = File.read(file_path)
        import_or_update_job(job_name, config_xml)
      end
    end

    def get_all_job_names
      url = "#{@jenkins_url}/api/json?tree=jobs[name]"
      response = HTTP.get(url, headers: { 'Authorization' => @auth_header })
      if response.status.success?
        jobs = JSON.parse(response.body.to_s)['jobs']
        jobs.map { |job| job['name'] }
      else
        logger.kerror("Error fetching job list: #{response.status}")
        []
      end
    rescue StandardError => e
      logger.kerror("Exception fetching job list: #{e.message}")
      []
    end

    def export_job(job_name)
      url = "#{@jenkins_url}/job/#{job_name}/config.xml"
      response = HTTP.get(url, headers: { 'Authorization' => @auth_header })
      return response.body.to_s if response.status.success?

      logger.kerror("Error exporting job #{job_name}: #{response.status}")
      nil
    rescue StandardError => e
      logger.kerror("Exception exporting job #{job_name}: #{e.message}")
      nil
    end

    def import_or_update_job(job_name, config_xml)
      url = "#{@jenkins_url}/job/#{job_name}/config.xml"
      logger.kinfo(url)
      begin
        logger.kinfo("Creating new job #{job_name}")
        create_new_job(job_name, config_xml)
      rescue StandardError
        logger.kinfo("Updating existing job #{job_name}")
        HTTP.put(url, body: config_xml, headers: {
                   'Authorization' => @auth_header,
                   'Content-Type' => 'application/xml'
                 })
      end
    end

    def self.arguments
      '[subcommand] [options]'
    end

    def self.usage
      "kscript jenkins list --host=jenkins.local\nkscript jenkins trigger --job=build"
    end

    def self.group
      'ci'
    end

    def self.author
      'kk'
    end

    def self.description
      'Jenkins job export/import automation.'
    end

    private

    def create_new_job(job_name, config_xml)
      url = "#{@jenkins_url}/createItem?name=#{job_name}"
      response = HTTP.post(url, body: config_xml, headers: {
                             'Authorization' => @auth_header,
                             'Content-Type' => 'application/xml'
                           })
      if response.status.success?
        logger.kinfo("Successfully created new job #{job_name}")
      else
        logger.kerror("Failed to create job #{job_name}: #{response.status}")
      end
    end
  end
end
