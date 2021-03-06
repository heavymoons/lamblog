# frozen_string_literal: true

require 'redcarpet'

def theme
  'default'
end

def view_name(name)
  :"#{theme}/#{name}"
end

def admin_view_name(name)
  :"admin/#{name}"
end

def t(translate_id)
  I18n.t(translate_id)
end

def markdown_to_html(markdown_text)
  renderer ||= Redcarpet::Render::HTML.new(
    with_toc_data: true,
    prettify: true
  )
  parser ||= Redcarpet::Markdown.new(renderer,
    tables: true,
    fenced_code_blocks: true,
    autolink: true,
    strikethrough: true,
    footnotes: true,
    no_intra_emphasis: true
  )
  parser.render(markdown_text)
end

def custom_html(name)
  @custom_html_cache ||= {}
  @custom_html_cache[name] ||= CustomHtmlService.load(name)
rescue StandardError
  @custom_html_cache[name] ||= ''
end

def setting(name, default = nil)
  ENV[name] || default
end

def datetime_text(time_string)
  time = Time.parse(time_string)
  format = setting('TIME_FORMAT', '%Y-%m-%d %H:%M')
  time.strftime(format)
end

def csrf_token
  session[:csrf]
end

def hidden_csrf_token
  %(<input type="hidden" name="authenticity_token" value="#{session[:csrf]}"/>)
end

def check_csrf_token
  params['authenticity_token'] == session[:csrf]
end

def send_flash(message)
  session[:flash] ||= []
  session[:flash].push message
end

def has_flash?
  !session[:flash].nil?
end

def retrieve_flash
  flashes = session[:flash] || []
  session.delete(:flash)
  flashes
end