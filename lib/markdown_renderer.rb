class MarkdownRenderer < Redcarpet::Render::HTML
  def initialize(options={})
    python = ENV["PYGMENTS_PYTHON"] || "python"
    RubyPython.configure :python_exe => python
    super
  end

  def block_code(code, language)
    begin
      Pygments.highlight code, :lexer => language, :options => { :encoding => "utf-8" }
    rescue
      Net::HTTP.post_form(URI.parse("http://pygments.appspot.com/"), "code" => code, "lang" => language).body
    end
  end
end
