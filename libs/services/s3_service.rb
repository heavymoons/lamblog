# frozen_string_literal: true

require 'aws-sdk-s3'
require 'mime/types'

# s3 access service
module S3Service
  module_function

  def list(key, _options = {})
    token = nil
    list = []
    loop do
      params = default_option
      params.merge!(
        prefix: key,
        delimiter: '/'
      )
      params[:continuation_token] = token unless token.nil?
      s3_result = client.list_objects_v2(params)
      list += s3_result[:contents].map do |content|
        content[:key].slice(key.size, content[:key].size)
      end
      token = s3_result[:next_continuation_token]
      break if token.nil?
    end
    list
  end

  def load(key, options = {})
    params = default_option.merge(options)
    params[:key] = key
    s3_result = client.get_object(params)
    s3_result[:body].read
  end

  def save(key, data, options = {})
    params = default_option.merge(options)
    params.merge!(
      content_type: MIME::Types.type_for(key).first.to_s,
      key: key,
      body: data
    )
    client.put_object(params)
  end

  def delete(key, options = {})
    params = default_option.merge(options)
    params.merge!(
      key: key
    )
    client.delete_object(params)
  end

  def save_public(key, data, options = {})
    save(key, data, options + { acl: 'public-read' })
  end

  def default_option
    {
      bucket: setting('S3_BUCKET')
    }
  end

  def client
    @client ||= Aws::S3::Client.new
  end
end
