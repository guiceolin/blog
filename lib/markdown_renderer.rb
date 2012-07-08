class MarkdownRenderer < Redcarpet::Render::HTML
  def initialize(options={})
    python = ENV["PYGMENTS_PYTHON"] || "python"
    RubyPython.configure :python_exe => python
    super
  end

  def block_code(code, language)
    Pygments.highlight code, :lexer => language, :options => { :encoding => "utf-8" }
  end
end
