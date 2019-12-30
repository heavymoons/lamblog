# frozen_string_literal: true

require 'hpricot'
require 'json'
require 'date'
require 'time'

def main
  xml_file = ARGV[0]
  raise "specify the wordpress export xml" if xml_file.nil?

  target_dir = ARGV[1] || './data'
  raise "target dir not exists: #{target_dir}" unless Dir.exists?(target_dir)

  list = load(xml_file)
  list.each do |post|
    filename = post[:entry_id] + '.json'
    File.open("#{target_dir}/#{filename}", "w") do |file|
      file.write(post.to_json)
    end
  end
end

def load(xml_file)
  xml = Hpricot::XML(File.read(xml_file))

  list = []
  (xml / :channel / :item).each do |item|
    title = item.at('title').inner_text

    md_date = DateTime.parse(item.at('wp:post_date').inner_text)
    date = md_date.strftime('%Y-%m-%d %H:%M')
    status = item.at('wp:status').inner_text
    published = (status == "publish" ? true : false)

    categories = []
    tags = []
    (item / :category).each do |cat|
      domain = cat["domain"]
      if domain == "category"
        categories << cat.inner_text
      elsif domain == "post_tag"
        tags << cat.inner_text
      end
    end

    keywords = categories + tags

    content = item.at('content:encoded').inner_text

    post_id = item.at('wp:post_id').inner_text
    entry_id = Time.parse(date).strftime('%Y%m%d-') + post_id
    data = {
      entry_id: entry_id,
      title: title || Time.parse(date).strftime('%Y年%m月%d日'),
      published_at: published ? Time.parse(date) : nil,
      tags: keywords || [],
      body: content,
      created_at: Time.parse(date),
      updated_at: Time.parse(date),
    }

    list << data
  end

  list
end

main
