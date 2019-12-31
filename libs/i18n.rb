# frozen_string_literal: true

require 'i18n'
require 'i18n/backend/fallbacks'
require 'rack/contrib'

use Rack::Locale

configure do
  I18n::Backend::Simple.include I18n::Backend::Fallbacks
  I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
  I18n.backend.load_translations
  I18n.enforce_available_locales = false
  I18n.available_locales = %i[ja en]
end

before do
  if env['HTTP_ACCEPT_LANGUAGE'].nil?
    locale = 'en'
  else
    accepts = env['HTTP_ACCEPT_LANGUAGE'].split(',').map do |lang|
      lang.split(';').first.split('-').first.to_sym
    end
    locale = accepts.select { |accept| I18n.available_locales.include?(accept) }.first
  end
  I18n.locale = locale
end
