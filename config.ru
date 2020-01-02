# frozen_string_literal: true

require 'sinatra'
require 'slim'
require_relative 'libs/initialize'
require_relative 'libs/i18n'

enable :sessions
set :session_secret, setting('SESSION_SECRET')

if development?
  require 'sinatra/reloader'
  Dir[File.join(__dir__, '**', '*.rb')].each { |f| also_reload f }
end

require_relative 'routes/error'
require_relative 'routes/public'
require_relative 'routes/admin'
require_relative 'routes/auth'

run Sinatra::Application
