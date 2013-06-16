module Blog
  class CoffeeHandler < Sinatra::Base
    set :views, File.join(File.dirname(__FILE__), "..", "assets", "coffee")

    get "/coffee/:filename.js" do
      coffee params[:filename].to_sym
    end
  end
end
