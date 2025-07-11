# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module Kscript
  class KkHnJobsUtils < Kscript::Base
    HN_JOBS_API = 'https://hacker-news.firebaseio.com/v0/jobstories.json'
    HN_ITEM_API = 'https://hacker-news.firebaseio.com/v0/item'

    def initialize(*args, **opts)
      super
      @limit = (args[0] || 10).to_i
    end

    def run(*args, **_opts)
      with_error_handling do
        limit = (args[0] || @limit || 10).to_i
        logger.kinfo("Fetching latest #{limit} Hacker News jobs...")
        job_ids = fetch_job_ids.first(limit)
        jobs = job_ids.map { |id| extract_job_info(fetch_job_item(id)) }
        display_jobs(jobs)
      end
    end

    def self.arguments
      '[limit]'
    end

    def self.usage
      'kscript hn_jobs [limit]'
    end

    def self.group
      'network'
    end

    def self.author
      'kk'
    end

    def self.description
      'Fetch and display latest Hacker News jobs: description and url.'
    end

    private

    def fetch_job_ids
      require_httpx
      response = HTTPX.get(HN_JOBS_API)
      response = response.first if response.is_a?(Array)
      raise "Failed to fetch job ids: #{response.status}" unless response.status == 200

      JSON.parse(response.body.to_s)
    end

    def fetch_job_item(id)
      require_httpx
      url = "#{HN_ITEM_API}/#{id}.json"
      response = HTTPX.get(url)
      response = response.first if response.is_a?(Array)
      raise "Failed to fetch job item #{id}: #{response.status}" unless response.status == 200

      JSON.parse(response.body.to_s)
    end

    # 只提取描述和 url
    def extract_job_info(item)
      {
        description: item['title'].to_s.strip,
        url: item['url'] || "https://news.ycombinator.com/item?id=#{item['id']}"
      }
    end

    def display_jobs(jobs)
      logger.kinfo('| 描述 | 链接 |')
      logger.kinfo('|------|------|')
      jobs.each do |job|
        logger.kinfo("| #{job[:description]} | [查看](#{job[:url]}) |")
      end
    end

    def require_httpx
      require 'httpx'
    rescue LoadError
      abort 'Missing dependency: httpx. Please run: gem install httpx'
    end
  end
end
