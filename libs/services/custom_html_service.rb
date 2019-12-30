# frozen_string_literal: true

# custom html service
module CustomHtmlService
  HTML_NAMES = [
    'header_top',
    'header_bottom',
    'footer_top',
    'footer_bottom',
    'content_top',
    'content_bottom',
    'index_top',
    'index_bottom',
    'entry_top',
    'entry_bottom',
    'archive_top',
    'archive_bottom',
    'tag_top',
    'tag_bottom',
  ]

  BASE_KEY = 'custom_htmls'

  module_function

  def list()
    key = "#{BASE_KEY}/"
    list = S3Service.list(key)
    list.map { |item| item.split('.').first }
  end

  def load(name, default = nil)
    S3Service.load(s3_key(name))
  rescue StandardError
    default
  end

  def save(name, html)
    S3Service.save(s3_key(name), html)
  end

  def delete(name)
    S3Service.delete(s3_key(name))
  end

  def s3_key(name)
    "#{BASE_KEY}/#{name}.html"
  end
end
