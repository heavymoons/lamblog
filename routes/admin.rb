# frozen_string_literal: true

require_relative '../libs/services/index_service'

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
  page = @params['page']&.to_i || 1
  slim admin_view_name('entries'), layout: admin_view_name('layout'), locals: {
    items: index,
    page: page
  }
end

get '/admin/entries/new' do
end

post '/admin/entries/' do
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
  entry.publish(params['do_publish'])
  entry.tags = params['tags'].split(' ')
  entry.save
  redirect "/admin/entries/#{entry_id}"
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

get '/admin/files' do
end

get '/admin/files/new' do
end

get '/admin/files/*' do
end

post '/admin/files/*' do
end

get '/admin/index/refresh' do
  IndexService.refresh
end
