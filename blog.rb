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

  configure :development do
    use Rack::Cache, :verbose => true

  end

  configure :production do
    use Rack::Cache, :metastore   => Dalli::Client.new(ENV["MEMCACHE_URL"], :username => ENV["MEMCACHE_USERNAME"], :password => ENV["MEMCACHE_PASSWORD"]),
                     :entitystore => "file:tmp/cache/rack/body"
  end

  get "/" do
    cache_control :public, :max_age => 60
    erb :index, :locals => { :posts => Post.all }
  end

  get "/:year/:month/:day/:slug" do
    post = Post.find_by_slug(params[:slug]) or raise Sinatra::NotFound
    raise Sinatra::NotFound unless post.published?

    cache_control :public, :max_age => 60
    etag post.cache_key

    erb :post, :locals => { :post => post }
  end

  get "/draft/:slug" do
    protected!
    post = Post.find_by_slug(params[:slug]) or raise Sinatra::NotFound
    erb :post, :locals =>  { :post => post }
  end

  helpers do
    def protected!
      unless authorized?
        response["WWW-Authenticate"] = 'Basic realm="Restricted Area"'
        throw :halt, [401, "Not authorized\n"]
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"]]
    end

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
