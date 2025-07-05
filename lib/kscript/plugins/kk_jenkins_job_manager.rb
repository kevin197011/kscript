# frozen_string_literal: true

# curl to execute this script:
# curl -sSL https://raw.githubusercontent.com/kevin197011/kscript/main/bin/jenkins-job-manager.rb | ruby

require 'http'
require 'base64'
require 'rexml/document'
require 'json'
require 'fileutils'
require 'kscript/base'

module Kscript
  class KkJenkinsJobManager < Base
    def run
      with_error_handling do
        puts 'Jenkins job manager executed.'
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
          puts "Exported job: #{job_name}"
        end
      end
    end

    def import_job_from_file(job_name)
      file_path = "jobs/#{job_name}.xml"
      if File.exist?(file_path)
        config_xml = File.read(file_path)
        import_or_update_job(job_name, config_xml)
      else
        puts "Job file #{file_path} does not exist!"
      end
    end

    def import_all_jobs_from_files
      job_files = Dir.glob('jobs/*.xml')
      job_files.each do |file_path|
        job_name = File.basename(file_path, '.xml')
        puts "Importing or updating job: #{job_name}"
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
        puts "Error fetching job list: #{response.status}"
        []
      end
    rescue StandardError => e
      puts "Exception fetching job list: #{e.message}"
      []
    end

    def export_job(job_name)
      url = "#{@jenkins_url}/job/#{job_name}/config.xml"
      response = HTTP.get(url, headers: { 'Authorization' => @auth_header })
      return response.body.to_s if response.status.success?

      puts "Error exporting job #{job_name}: #{response.status}"
      nil
    rescue StandardError => e
      puts "Exception exporting job #{job_name}: #{e.message}"
      nil
    end

    def import_or_update_job(job_name, config_xml)
      url = "#{@jenkins_url}/job/#{job_name}/config.xml"
      puts url
      begin
        puts "Creating new job #{job_name}"
        create_new_job(job_name, config_xml)
      rescue StandardError
        puts "Updating existing job #{job_name}"
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
      "kscript jenkins_job_manager list --host=jenkins.local\nkscript jenkins_job_manager trigger --job=build"
    end

    def self.group
      'ci'
    end

    def self.author
      'kk'
    end

    private

    def create_new_job(job_name, config_xml)
      url = "#{@jenkins_url}/createItem?name=#{job_name}"
      response = HTTP.post(url, body: config_xml, headers: {
                             'Authorization' => @auth_header,
                             'Content-Type' => 'application/xml'
                           })
      if response.status.success?
        puts "Successfully created new job #{job_name}"
      else
        puts "Failed to create job #{job_name}: #{response.status}"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  jenkins_url = 'https://jenkins.devops.io'
  user = 'kk'
  password = 'xxxxxxxxxxxxxxxxxxxxxxxx' # Jenkins API Token Or password
  Kscript::KkJenkinsJobManager.new(jenkins_url, user, password).run
end
