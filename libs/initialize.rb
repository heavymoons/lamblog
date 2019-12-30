# frozen_string_literal: true

require 'dotenv'
Dotenv.load

require_relative 'services/s3_service'
require_relative 'helper'

ENV['TZ'] = setting('TimeZone', 'UTC')
