# frozen_string_literal: true

require_relative '../libs/services/index_service'

get '/' do
  index = IndexService.load
  index.filter(published: true)
  index.sort(published_at: :desc)

  limit = 10
  item_count = index.count
  page = params['page']&.to_i || 1
  offset = limit * (page - 1)

  index.limit(limit, offset)

  entries = index.load_entries

  slim view_name('index'), layout: view_name('layout'), locals: {
    entries: entries,
    page: page,
    item_count: item_count,
    limit: limit
  }
end

get %r{/(\d{4})/(\d{2})/.*} do |year, month|
  redirect "/#{year}/#{month}"
end

get %r{/(\d{4})/(\d{2})} do |year, month|
  index = IndexService.load
  published_from = "#{year}-#{month}-01"
  published_to = "#{year}-#{month}-32"
  index.filter(published_from: published_from, published_to: published_to)
  index.sort(published_at: :asc)

  limit = 10
  item_count = index.count
  page = params['page']&.to_i || 1
  offset = limit * (page - 1)

  index.limit(limit, offset)

  entries = index.load_entries

  slim view_name('index'), layout: view_name('layout'), locals: {
    entries: entries,
    page: page,
    item_count: item_count,
    limit: limit
  }
end

get '/entry/:entry_id' do |entry_id|
  entry = EntryService.load(entry_id)
  raise Sinatra::NotFound unless entry.published?

  slim view_name('entry'), layout: view_name('layout'), locals: { entry: entry }
end

get '/tag/*' do |keyword|
  index = IndexService.load
  index.filter(published: true, tags: [keyword])
  index.sort(published_at: :desc, created_at: :desc)

  limit = 10
  item_count = index.count
  page = params['page']&.to_i || 1
  offset = limit * (page - 1)

  index.limit(limit, offset)

  entries = index.load_entries

  slim view_name('tag'), layout: view_name('layout'), locals: {
    keyword: keyword,
    entries: entries,
    page: page,
    item_count: item_count,
    limit: limit
  }
end

get '/files/*' do |path|
  content_type MIME::Types.type_for(path).first.to_s
  FileService.load(path)
end

get '/(*).(*)' do |filename, ext|
  path = "#{__dir__}/../static/#{filename}.#{ext}"
  not_found unless File.exists?(path)
  content_type MIME::Types.type_for(path).first.to_s
  File.read(path)
end
