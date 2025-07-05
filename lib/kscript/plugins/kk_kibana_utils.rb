# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

module Kscript
  class KkKibanaUtils < Base
    def run
      with_error_handling do
        logger.kinfo('Kibana utils executed.')
      end
    end

    def initialize(project_name, project_env, base_url, username, password)
      @base_url = base_url
      @username = username
      @password = password
      @project_name = project_name
      @project_env = project_env
      @space_name = "#{project_name}-#{project_env}"

      # Check and create space if it doesn't exist
      create_space unless space_exists?
    end

    # Check if the space exists
    def space_exists?
      url = "#{@base_url}/api/spaces/space/#{@space_name}"
      response = client.get(url, headers: kbn_headers)
      response.status.success?
    rescue StandardError => e
      logger.kerror("Error checking space existence: #{e.message}")
      false
    end

    # Create a new space
    def create_space
      url = "#{@base_url}/api/spaces/space"
      body = {
        id: @space_name,
        name: @space_name,
        description: "Space for #{@project_name} #{@project_env} environment",
        color: "##{SecureRandom.hex(3)}", # Random color
        initials: "#{@project_name[0]}#{@project_env[0]}".upcase
      }

      response = client.post(url, json: body, headers: kbn_headers)
      if response.status.success?
        logger.kinfo("Space '#{@space_name}' created successfully!")
      else
        logger.kerror("Failed to create space '#{@space_name}': #{response.body}")
      end
    rescue StandardError => e
      logger.kerror("Error creating space: #{e.message}")
    end

    # Return the HTTP client with authentication
    def client
      @client ||= HTTP.basic_auth(user: @username, pass: @password)
    end

    # Fetch all indices from Kibana
    def indices
      response = client.get("#{@base_url}/api/index_management/indices", headers: kbn_headers)
      handle_response(response) { |body| JSON.parse(body).map { |item| item['name'] } }
    end

    # Delete space all index
    def delete_dataviews
      url = "#{@base_url}/s/#{@space_name}/api/content_management/rpc/delete"
      get_dataviews.each do |index|
        body = {
          'contentTypeId' => 'index-pattern',
          'id' => index['id'],
          'options' => {
            'force' => true
          },
          'version' => 1
        }
        client.post(url, json: body, headers: kbn_headers)
      end
    end

    # Add a new index to Kibana
    def add_index(index_name)
      uuid = SecureRandom.uuid
      url = "#{@base_url}/s/#{@space_name}/api/content_management/rpc/create"
      body = index_body(index_name, uuid)

      response = client.post(url, json: body, headers: kbn_headers)
      if response.status.success?
        logger.kinfo("#{index_name} Index creation successful!")
      else
        handle_error(response, index_name)
      end
    end

    # Add all relevant indices to Kibana
    def add_all_index
      delete_dataviews
      indices.each do |index|
        unless index =~ /#{@project_name}/i && index =~ /#{@project_env}/i && index =~ /#{Time.now.strftime('%Y.%m.%d')}/
          next
        end

        add_index(index.gsub(/-\d{4}\.\d{2}\.\d{2}/, ''))
      end
    end

    def create_role
      url = "#{@base_url}/api/security/role/#{@project_name}?createOnly=true"
      request_body = {
        'elasticsearch' => {
          'cluster' => [],
          'indices' => [
            {
              'names' => ["*#{@project_name}*"],
              'privileges' => ['read']
            }
          ],
          'run_as' => []
        },
        'kibana' => [
          {
            'spaces' => ["#{@project_name}-prod", "#{@project_name}-uat"],
            'base' => [],
            'feature' => {
              'discover' => ['read']
            }
          }
        ]
      }.to_json
      client.put(url, body: request_body, headers: kbn_headers)
      logger.kinfo("Create #{@project_name} user role sucessed!")
    end

    def create_user
      url = "#{@base_url}/internal/security/users/#{@project_name}"
      request_body = {
        'password' => '123456',
        'username' => @project_name,
        'full_name' => @project_name,
        'email' => "#{@project_name}@devops.io",
        'roles' => [@project_name]
      }.to_json
      client.post(url, body: request_body, headers: kbn_headers)
      logger.kinfo("Create #{@project_name} user sucessed!")
    end

    def self.arguments
      '[subcommand] [options]'
    end

    def self.usage
      "kscript kibana export --host=localhost --index=log-*\nkscript kibana import --file=dashboard.json"
    end

    def self.group
      'elastic'
    end

    def self.author
      'kk'
    end

    def self.description
      'Kibana automation: space, index, user, role management.'
    end

    private

    # Fetch all index id
    def get_dataviews
      url = "#{@base_url}/s/#{@space_name}/api/content_management/rpc/search"
      # Data payload
      body = {
        'contentTypeId' => 'index-pattern',
        'query' => { 'limit' => 10_000 },
        'options' => { 'fields' => %w[title type typeMeta name] },
        'version' => 1
      }
      JSON.parse(client.post(url, json: body, headers: kbn_headers))['result']['result']['hits']
    end

    # Construct the body for creating an index
    def index_body(index_name, uuid)
      {
        "contentTypeId": 'index-pattern',
        "data": {
          "fieldAttrs": '{}',
          "title": "#{index_name}*",
          "timeFieldName": '@timestamp',
          "sourceFilters": '[]',
          "fields": '[]',
          "fieldFormatMap": '{}',
          "runtimeFieldMap": '{}',
          "name": index_name,
          "allowHidden": false
        },
        "options": {
          "id": uuid,
          "overwrite": false
        },
        "version": 1
      }
    end

    # Generate the required headers, including kbn-xsrf
    def kbn_headers
      { 'kbn-xsrf' => 'true' }
    end

    # Handle the response from Kibana
    def handle_response(response)
      if response.status.success?
        yield response.body
      else
        handle_error(response)
      end
    end

    # Handle errors from Kibana API responses
    def handle_error(response, index_name = nil)
      error_message = "Error: #{response.status} - #{response.body}"
      if index_name
        logger.kerror("#{index_name} Failed to create index. #{error_message}")
      else
        logger.kerror("Error fetching indices: #{error_message}")
      end
    end
  end
end
