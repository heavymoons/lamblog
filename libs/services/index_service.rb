# frozen_string_literal: true

require 'json'
require_relative 'entry_service'
require_relative '../models/index'

# entry index service
module IndexService
  module_function

  def load
    json = S3Service.load(index_key)
    index = JSON.parse(json)
    Index.new(index)
  end

  def save(index)
    json = index.to_json
    S3Service.save(index_key, json)
  end

  def refresh
    index = {}
    files, _ = S3Service.list(EntryService.key_base)
    files.each do |entry_key|
      entry_id = key_to_entry_id(entry_key)
      entry = EntryService.load(entry_id)
      index[entry_id] = Index::Item.new(entry.to_h)
    end
    save(index)
  end

  def update_entry(entry)
    index = load
    index.update_entry(entry)
    save(index)
  end

  def delete_entry(entry_id)
    index = load
    index.delete_entry(entry_id)
    save(index)
  end

  def key_to_entry_id(key)
    parts = key.split('.')
    parts.pop
    parts.join('.')
  end

  def index_key
    'indexes/index.json'
  end
end
