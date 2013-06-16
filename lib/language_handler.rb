module Blog
  class LanguageHandler < Sinatra::Base

    get "/language/:lang" do
      response.set_cookie 'lang', value: params[:lang], path: '/', expires_at: 'session'
      redirect to('/')
    end
  end
end
