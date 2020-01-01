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

  def check_config
    keys = %w[AWS_REGION S3_BUCKET]
    keys.each do |key|
      raise "require config: #{key}" if ENV[key].nil?
    end
  end
end

InitAws.main
