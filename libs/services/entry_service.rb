# frozen_string_literal: true

require 'json'
require 'hashids'
require_relative '../models/entry'

# entry service
module EntryService
  module_function

  def new_entry
    Entry.new({})
  end

  def load(entry_id)
    json = S3Service.load(key(entry_id))
    entry_data = JSON.parse(json)
    Entry.new(entry_data)
  end

  def save(entry_data)
    S3Service.save(key(entry_data.entry_id), entry_data.to_json)
  end

  def delete(entry_id)
    S3Service.delete(key(entry_id))
    IndexService.delete_entry(entry_id)
  end

  def key_base
    'entries/'
  end

  def key(entry_id)
    "#{key_base}#{entry_id}.json"
  end
end
