# frozen_string_literal: true

# Copyright (c) 2025 Kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'kscript'

# AWS S3 文件上传测试工具
# 用法示例：
#   kscript aws_s3 --file local.txt --bucket my-bucket --key test.txt --region ap-northeast-1 --access_key xxx --secret_key yyy
#
# 依赖：aws-sdk-s3（已在主入口 require）

module Kscript
  class KkAwsS3Utils < Base
    # 初始化，支持所有参数通过 CLI 传递
    def initialize(*args, **opts)
      super
      # 兼容 --file test.txt 以及 --file=test.txt
      @file = opts[:file] || args[0]
      @bucket = opts[:bucket] || args[1] || ENV.fetch('AWS_BUCKET', nil)
      @key = opts[:key] || args[2]
      @region = opts[:region] || ENV.fetch('AWS_REGION', nil)
      @access_key = opts[:access_key] || ENV.fetch('AWS_ACCESS_KEY_ID', nil)
      @secret_key = opts[:secret_key] || ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    end

    # 主入口
    def run(*_args, **_opts)
      with_error_handling do
        upload_file_to_s3
      end
    end

    # 上传文件到 S3
    def upload_file_to_s3
      validate_params!
      logger.kinfo('Uploading file to S3...', file: @file, bucket: @bucket, key: @key, region: @region)
      s3 = Aws::S3::Resource.new(
        region: @region,
        access_key_id: @access_key,
        secret_access_key: @secret_key
      )
      obj = s3.bucket(@bucket).object(@key)
      obj.upload_file(@file)
      url = obj.public_url
      logger.kinfo('Upload success', url: url)
    end

    # 参数声明
    def self.arguments
      '--file FILE --bucket BUCKET --key KEY --region REGION --access_key AK --secret_key SK'
    end

    # 用法
    def self.usage
      'kscript aws_s3 --file local.txt --bucket my-bucket --key test.txt --region ap-northeast-1 --access_key xxx --secret_key yyy'
    end

    # 分组
    def self.group
      'cloud'
    end

    # 作者
    def self.author
      'kk'
    end

    # 描述
    def self.description
      'Upload a file to AWS S3 for testing.'
    end

    private

    # 校验参数
    def validate_params!
      missing = []
      missing << 'file' unless @file
      missing << 'bucket' unless @bucket
      missing << 'key' unless @key
      missing << 'region' unless @region
      missing << 'access_key' unless @access_key
      missing << 'secret_key' unless @secret_key
      unless missing.empty?
        logger.kerror('Missing required parameters', missing: missing)
        logger.kinfo(self.class.usage)
        raise ArgumentError, "Missing: #{missing.join(', ')}"
      end
      return if File.exist?(@file)

      logger.kerror('File not found', file: @file)
      raise ArgumentError, "File not found: #{@file}"
    end
  end
end
