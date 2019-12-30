# frozen_string_literal: true

# custom html service
module CustomHtmlService
  module_function

  def load(name, default = nil)
    @custom_htmls ||= {}
    @custom_htmls[name] ||= S3Service.load(s3_key(name))
  rescue StandardError
    @custom_htmls[name] ||= default
  end

  def save(name, html)
    S3Service.save(s3_key(name), html)
  end

  def s3_key(name)
    "custom_html/#{name}.html"
  end
end
