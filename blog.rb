require 'sinatra/cookies'


class Blog < Sinatra::Base
  helpers Sinatra::Cookies

  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
  enable :logging

  use CoffeeHandler
  use SassHandler

  configure :production do
    memcache_client = Dalli::Client.new ENV["MEMCACHE_URL"],
                                        :username => ENV["MEMCACHE_USERNAME"],
                                        :password => ENV["MEMCACHE_PASSWORD"]

    use Rack::Cache, :entitystore => memcache_client,
                     :metastore   => memcache_client
  end

  get "/language/:lang" do
    response.set_cookie 'lang', value: params[:lang], path: '/', expires_at: 'session'
    redirect to('/')
  end

  get "/" do
    cache_control :public, :max_age => 60
    erb :index, :locals => { :posts => Post.all }
  end

  get "/rss" do
    cache_control :public, :max_age => 60
    builder :rss
  end

  get "/:year/:month/:day/:slug" do
    post = Post.find_by_slug(params[:slug]) or raise Sinatra::NotFound
    raise Sinatra::NotFound unless post.published?

    cache_control :public, :max_age => 60
    etag post.cache_key

    erb :post, :locals => { :post => post }
  end

  get "/draft/:slug" do
    post = Post.find_by_slug(params[:slug]) or raise Sinatra::NotFound
    erb :post, :locals =>  { :post => post }
  end

  helpers do
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
