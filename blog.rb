class CoffeeHandler < Sinatra::Base
  set :views, File.join(File.dirname(__FILE__), "assets", "coffee")

  get "/coffee/:filename.js" do
    coffee params[:filename].to_sym
  end
end

class SassHandler < Sinatra::Base
  set :views, File.join(File.dirname(__FILE__), "assets", "sass")

  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname(__FILE__)
      config.sass_dir = "assets/sass"
      config.css_dir = "public"
    end
  end

  get "/style.css" do
    headers 'Content-Type' => 'text/css; charset=utf-8'
    sass :style, Compass.sass_engine_options
  end
end

class Blog < Sinatra::Base
  enable :logging

  use CoffeeHandler
  use SassHandler

  get "/" do
    erb :index, :locals => { :posts => Post.all }
  end

  get "/:year/:month/:day/:slug" do
    post = Post.find_by_slug(params[:slug]) or raise Sinatra::NotFound
    erb :post, :locals => { :post => post }
  end

  helpers do
    def markdown(text)
      options = {
        :fenced_code_blocks => true,
        :strikethrough => true,
        :autolink => true,
        :hard_wrap => true
      }

      Redcarpet::Markdown.new(MarkdownRenderer, options).render(text)
    end
  end
end
