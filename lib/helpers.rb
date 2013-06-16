module Blog
  module Helpers

    def published_at(date)
      return <<HTML
<p class="date">
  #{ t :published_at }:
  <span class="date">#{!date.nil?? l(date) : nil }</span>
</p>
HTML
    end

    def markdown(text)
      options = {
        :fenced_code_blocks => true,
        :strikethrough => true,
        :autolink => true,
        :hard_wrap => true
      }

      @renderer ||= Redcarpet::Markdown.new(MarkdownRenderer, options)
      @renderer.render(text)
    end

    def introduction(post)
      Nokogiri::XML(markdown(post.body)).at_xpath("/p").content
    end

    def get_locale
      cookies[:lang] || "pt"
    end

    def t(term, options={})
      I18n.t(term, options.merge!(locale: get_locale))
    end

    def l(datetime, options={})
      I18n.l(datetime, options.merge!(locale: get_locale))
    end

  end
end
