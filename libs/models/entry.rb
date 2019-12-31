# frozen_string_literal: true

class Entry
  attr_accessor :entry_id, :title, :body, :body_html, :tags, :created_at, :updated_at, :published_at

  def initialize(entry_data)
    @entry_id = entry_data['entry_id']
    @title = entry_data['title']
    @body = entry_data['body']
    @body_html = entry_data['body_html']
    @tags = entry_data['tags'] || []
    @created_at = entry_data['created_at']
    @updated_at = entry_data['updated_at']
    @published_at = entry_data['published_at']
  end

  def publish(type = 'yes')
    case type
    when 'no'
      @published_at = nil
    when 'update'
      @published_at = Time.now
    else
      @published_at ||= Time.now
    end
  end

  def save
    @entry_id ||= new_id
    @created_at ||= Time.now
    @updated_at = Time.now
    @body_html = markdown(body)
    unless @tags.instance_of?(Array)
      @tags = @tags.to_s.split(/[\s　]+/).reject(&:empty?)
    end
    EntryService.save(self)
    IndexService.update_entry(self)
  end

  def delete
    EntryService.delete(entry_id)
  end

  def new_id
    hashids = Hashids.new
    id = hashids.encode(Time.now.strftime('%6N').to_i)
    Time.now.strftime('%Y%m%d') + '-' + id
  end

  def published?
    !published_at.nil?
  end

  def url
    "/entry/#{entry_id}"
  end

  def to_h
    {
      'entry_id' => entry_id,
      'title' => title,
      'body' => body,
      'body_html' => body_html,
      'tags' => tags,
      'created_at' => created_at,
      'updated_at' => updated_at,
      'published_at' => published_at
    }
  end

  def to_json(*_args)
    to_h.to_json
  end
end
