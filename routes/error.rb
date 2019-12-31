# frozen_string_literal: true

require 'aws-sdk-s3'

not_found do
  slim view_name('not_found'), layout: view_name('layout')
end

error 403 do
  '403 Access Forbidden'
end

error 500 do
  '500 Internal Server Error'
end

error Aws::S3::Errors::NoSuchKey do
  not_found
end
