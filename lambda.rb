# frozen_string_literal: true

require 'json'
require 'rack'

$app ||= Rack::Builder.parse_file("#{__dir__}/config.ru").first

def handler(event:, context:)
  raw_body = event['body'] || ''
  body = if event['isBase64Encoded']
    Base64.decode64(raw_body)
  else
    raw_body
  end

  querystring = event['queryStringParameters'] || nil
  querystring = Rack::Utils.build_query(querystring) unless querystring.nil?

  env = {
    'REQUEST_METHOD' => event['httpMethod'],
    'SCRIPT_NAME' => '',
    'PATH_INFO' => event['path'] || '',
    'QUERY_STRING' => querystring,
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => 443,

    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => 'https',
    'rack.input' => StringIO.new(body),
    'rack.errors' => $stderr
  }

  event['headers']&.each do |key, value|
    converted_key = key.upcase.gsub('-', '_')
    env["HTTP_#{converted_key}"] = value
    env[converted_key] = value if env[converted_key].nil?
  end

  begin
    status, headers, body = $app.call(env)

    body_content = ''
    body.each do |item|
      body_content += item.to_s
    end

    isBase64Encoded = false
    contentHandling = 'CONVERT_TO_TEXT'

    unless body_content.valid_encoding?
      isBase64Encoded = true
      contentHandling = 'CONVERT_TO_BINARY'
      body_content = Base64.encode64(body_content)
    end

    response = {
      'statusCode' => status,
      'headers' => headers,
      'body' => body_content,
      'isBase64Encoded' => isBase64Encoded,
      'contentHandling' => contentHandling
    }
  rescue Exception => e
    response = {
      'statusCode' => 500,
      'body' => e
    }
  end
  response
end
