class MarkdownRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    begin
      Pygments.highlight code, :lexer => language, :options => { :encoding => "utf-8" }
    rescue LoadError, StandardError
      Net::HTTP.post_form(URI.parse("http://pygments.appspot.com/"), "code" => code, "lang" => language).body
    end
  end
end
