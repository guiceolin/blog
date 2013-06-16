module Blog
  class RssHandler < Sinatra::Base

    get "/rss" do
      cache_control :public, :max_age => 60
      builder :rss
    end
  end
end
