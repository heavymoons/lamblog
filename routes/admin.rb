# frozen_string_literal: true

require_relative '../libs/services/index_service'
require_relative '../libs/services/custom_html_service'
require_relative '../libs/services/file_service'

before '/admin/*' do
  not_found unless session[:login]
end

get '/admin/' do
  slim admin_view_name('index'), layout: admin_view_name('layout')
end

get '/admin/entries' do
  index = IndexService.load
  case params['published']
  when 'true'
    index.filter(published: true)
  when 'false'
    index.filter(published: false)
  end
  tag = params['tag']
  index.filter(tags: [tag]) unless tag.nil?

  index.sort(updated_at: :desc)

  limit = 100
  item_count = index.count
  page = params['page']&.to_i || 1
  offset = limit * (page - 1)

  index.limit(limit, offset)

  slim admin_view_name('entries'), layout: admin_view_name('layout'), locals: {
    items: index,
    page: page,
    item_count: item_count,
    limit: limit
  }
end

get '/admin/entries/new' do
  entry = EntryService.new_entry
  slim admin_view_name('edit_entry'), layout: admin_view_name('layout'), locals: {
    entry: entry
  }
end

post '/admin/entries/new' do
  raise 'csrf check error' unless check_csrf_token

  entry = EntryService.new_entry
  entry.entry_id = params['entry_id'] unless params['entry_id'].to_s.size == 0
  entry.body = params['body']
  entry.title = params['title']
  entry.tags = params['tags'].split(' ')
  entry.publish(params['do_publish'])
  entry.save
  redirect "/admin/entries/#{entry.entry_id}"
end

get '/admin/entries/:entry_id/delete' do |entry_id|
  entry = EntryService.load(entry_id)
  slim admin_view_name('delete_entry'), layout: admin_view_name('layout'), locals: { entry: entry }
end

post '/admin/entries/:entry_id/delete' do |entry_id|
  raise 'csrf check error' unless check_csrf_token

  entry = EntryService.load(entry_id)
  entry.delete
  redirect '/admin/entries'
end

get '/admin/entries/:entry_id' do |entry_id|
  entry = EntryService.load(entry_id)
  slim admin_view_name('edit_entry'), layout: admin_view_name('layout'), locals: {
    entry: entry
  }
end

post '/admin/entries/preview' do
  body = params['body']
  markdown(body)
end

post '/admin/entries/:entry_id' do |entry_id|
  raise 'csrf check error' unless check_csrf_token

  entry = EntryService.load(entry_id)
  entry.body = params['body']
  entry.title = params['title']
  entry.tags = params['tags'].split(' ')
  entry.publish(params['do_publish'])
  entry.save
  redirect "/admin/entries/#{entry_id}"
end

get '/admin/custom_htmls' do
  custom_htmls = CustomHtmlService.list
  default_names = CustomHtmlService::HTML_NAMES

  slim admin_view_name('custom_htmls'), layout: admin_view_name('layout'), locals: {
    custom_htmls: custom_htmls,
    default_names: default_names
  }
end

get '/admin/custom_htmls/:name/delete' do |name|
  html = CustomHtmlService.load(name)

  slim admin_view_name('delete_custom_html'), layout: admin_view_name('layout'), locals: {
    name: name,
    html: html
  }
end

post '/admin/custom_htmls/:name/delete' do |name|
  raise 'csrf check error' unless check_csrf_token

  CustomHtmlService.delete(name)
  redirect("/admin/custom_htmls")
end

get '/admin/custom_htmls/:name' do |name|
  html = CustomHtmlService.load(name)

  slim admin_view_name('edit_custom_html'), layout: admin_view_name('layout'), locals: {
    name: name,
    html: html
  }
end

post '/admin/custom_htmls/:name' do |name|
  raise 'csrf check error' unless check_csrf_token

  html = params['html']
  CustomHtmlService.save(name, html)
  redirect "/admin/custom_htmls/#{name}"
end


get '/admin/files' do
  redirect '/admin/files/'
end

get '/admin/files/new' do
end

get '/admin/files/*' do |path|
  filelist, dirlist = FileService.list(path)
  slim admin_view_name('files'), layout: admin_view_name('layout'), locals: {path: path, dirlist: dirlist, filelist: filelist}
end

post '/admin/files/*' do |path|
  raise 'csrf check error' unless check_csrf_token

  if params['delete_file']
    fullpath = File.join(path, params['delete_file'])
    FileService.delete(fullpath)
  end

  if params['dirname'].to_s.size > 0
    fullpath = File.join(path, params['dirname'])
    FileService.mkdir(fullpath)
  end

  if params['files']
    params['files'].each do |file|
      next if file.instance_of?(String) # Lambda support
      filename = File.join(path, file['filename'])
      data = file['tempfile'].read
      FileService.save(filename, data)
    end
  end
  redirect "/admin/files/#{path}"
end

get '/admin/index/refresh' do
  IndexService.refresh
  redirect '/admin'
end
