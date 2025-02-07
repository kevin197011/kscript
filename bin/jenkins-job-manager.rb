# frozen_string_literal: true

require 'http'
require 'base64'
require 'rexml/document'
require 'json'
require 'fileutils'

$stdout.sync = true

class JenkinsJobManager
  def initialize(jenkins_url, user, password)
    @jenkins_url = jenkins_url
    @user = user
    @password = password
    @auth_header = "Basic #{Base64.strict_encode64("#{@user}:#{@password}")}"
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
    begin
      response = HTTP.get(url, headers: { 'Authorization' => @auth_header })
      if response.status.success?
        puts "Updating existing job #{job_name}"
        HTTP.put(url, body: config_xml, headers: {
                   'Authorization' => @auth_header,
                   'Content-Type' => 'application/xml'
                 })
      end
    rescue HTTP::ConnectionError, HTTP::ResponseError => e
      if e.message.include?('404')
        puts "Creating new job #{job_name}"
        create_new_job(job_name, config_xml)
      else
        puts "Error updating job #{job_name}: #{e.message}"
      end
    end
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

jenkins_url = 'https://jenkins.devops.io'
user = 'kk'
password = 'xxxxxxxxxxxxxxxxxxxxx' # Jenkins API Token Or password
manager = JenkinsJobManager.new(jenkins_url, user, password)

manager.export_all_jobs
