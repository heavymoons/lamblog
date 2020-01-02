# frozen_string_literal: true

# entry index class
class Index
  attr_accessor :items

  def initialize(index)
    @items = index.map do |entry_id, entry_data|
      [entry_id, Item.new(entry_data)]
    end.to_h
  end

  def load_entries
    entries = []
    items.each do |entry_id, _|
      entries.push EntryService.load(entry_id)
    end
    entries
  end

  def delete_entry(entry_id)
    items.delete(entry_id)
  end

  def update_entry(entry)
    items[entry.entry_id] = Item.new(entry.to_h)
  end

  def filter(tags: [], published: nil, published_from: nil, published_to: nil)
    @items = items.select do |_, item|
      result = true
      unless !result || tags.empty?
        result &= tags.all? { |tag| item.tags.include?(tag) }
      end
      unless !result || published.nil?
        result &= published ? !item.published_at.nil? : item.published_at.nil?
      end
      unless !result || (published_from.nil? && published_to.nil?)
        unless published_from.nil?
          result &= false if item.published_at <= published_from
        end
        unless published_to.nil?
          result &= false if item.published_at >= published_to
        end
      end

      result
    end
    self
  end

  def sort(conditions = {})
    return if conditions.keys.empty?

    @items = items.sort do |(_, v1), (_, v2)|
      order = nil
      conditions.each do |key, asc_or_desc|
        if order.nil? || order != 0
          order = v1.send(key) <=> v2.send(key)
          order = asc_or_desc == :asc ? order : order.to_i * -1
        end
      end
      order
    end
    self
  end

  def limit(limit, offset = 0)
    @items = Hash[*items.to_a.slice(offset, limit).flatten]
  end

  def count
    items.count
  end

  def year_months
    result = {}
    @items.each do |_, item|
      year_month = Time.parse(item.published_at).strftime('%Y/%m')
      result[year_month] ||= 0
      result[year_month] += 1
    end
    result.sort.reverse
  end

  def tags
    result = {}
    @items.each do |_, item|
      item.tags.each do |tag|
        result[tag] ||= 0
        result[tag] += 1
      end
    end
    result.sort { |(_, v1), (_, v2)| (v1 <=> v2) * -1 }
  end

  def to_json(state = nil)
    items.to_json(state)
  end

  # index item class
  class Item
    attr_accessor :entry_id, :title, :published_at, :created_at, :updated_at, :tags

    def initialize(data)
      @entry_id = data['entry_id']
      @title = data['title']
      @published_at = data['published_at']
      @created_at = data['created_at']
      @updated_at = data['updated_at']
      @tags = data['tags'] || []
    end

    def url
      "/entry/#{entry_id}"
    end

    def to_h
      {
        'entry_id' => entry_id,
        'title' => title,
        'published_at' => published_at,
        'created_at' => created_at,
        'updated_at' => updated_at,
        'tags' => tags
      }
    end

    def to_json(state = nil)
      to_h.to_json(state)
    end
  end
end
