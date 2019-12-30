# frozen_string_literal: true

require 'dotenv'
require 'aws-sdk-s3'
require_relative '../libs/initialize'
require_relative '../libs/helper'
require_relative '../libs/services/entry_service'
require_relative '../libs/services/index_service'

# initialize aws resources
module InitAws
  module_function

  def main
    check_config

    create_bucket
    create_default_entry
  end

  def client
    @client ||= Aws::S3::Client.new
  end

  def create_default_entry
    IndexService.refresh
    entry = EntryService.new_entry
    entry.title = 'First Entry'
    entry.body = 'This is my first entry.'
    entry.publish
    entry.save
  end

  def create_bucket
    if bucket_exists?
      puts "bucket already exists: #{ENV['S3_BUCKET']}"
      return
    end

    params = {
      bucket: ENV['S3_BUCKET'],
      create_bucket_configuration: {
        location_constraint: ENV['AWS_REGION']
      },
      acl: 'private'
    }
    client.create_bucket(params)
  end

  def bucket_exists?
    params = {
      bucket: ENV['S3_BUCKET']
    }
    client.head_bucket(params)
    true
  rescue StandardError
    false
  end

  def check_config
    keys = %w[AWS_REGION S3_BUCKET]
    keys.each do |key|
      raise "require config: #{key}" if ENV[key].nil?
    end
  end
end

InitAws.main
