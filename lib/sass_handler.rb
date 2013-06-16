module Blog
  class SassHandler < Sinatra::Base
    set :views, File.join(File.dirname(__FILE__),"..", "assets", "sass")

    configure do
      Compass.configuration do |config|
        config.project_path = File.join(File.dirname(__FILE__), "..")
        config.sass_dir = "assets/sass"
        config.css_dir = "public"
      end
    end

    get "/style.css" do
      headers 'Content-Type' => 'text/css; charset=utf-8'
      sass :style, Compass.sass_engine_options
    end
  end


end
