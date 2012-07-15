title: Codificando meu próprio blog
author: Rodrigo Navarro
date: 2012-07-14

_Engines_ de blog devem ser uma das coisas mais populares da internet. Até mesmo quem não trabalha com desenvolvimento já deve ter ouvido falar do [Wordpress](http://wordpress.com/) por exemplo. Além disso, existem também diversos serviços de ótima qualidade que permite qualquer um começar o seu blog em minutos. E claro que não acaba por aí, existem _muitos_ projetos de ótima qualidade disponíveis gratuitamente e com código aberto, como o próprio Wordpress, o [Movable Type](http://www.movabletype.org/), [Octpress](http://octopress.org/docs/), [Typo](http://typosphere.org), e a lista vai longe. Eu, por exemplo trabalho muito com _Ruby_, que é uma linguagem que ficou muito famosa por conta do _Rails_, que por sua vez teve grande parte da sua fama pelo vídeo do "Programe seu blog em 15 minutos", ou seja, opções com certeza não faltam.

E no meio de tantas opções de qualidade já prontas, por que alguém iria querer "reinventar a roda" e escrever sua própria _engine de blog_? Cada um que já fez isso tem sua própria resposta, mas para mim, creio que foi pelo puro prazer de programar, e claro, é muito legal quando você tem a oportunidade de fazer as coisas do seu jeito, com as exatas funcionalidades que você deseja.

Nesse artigo irei mostrar _como_ fiz para montar esse blog, bem como algumas coisas que aprendi nesse processo.

# Escolhendo as funcionalidades

A maior parte dos sistemas de blogs _opensource_ fornecem funcionalidades muito legais que facilitam muito a vida de leigos, como editores _HTML_, área de admnistração, customizações através de plugins, suporte a múltiplos autores e etc. Acontece que para o meu caso, nenhuma dessas _features_ são realmente necessárias, afinal, quem irá escrever os artigos desse blog não é um jornalista ou alguém leigo em desenvolvimento web.

Outro ponto importante para ser citado é que não vejo necessidade de guardar os artigos em algum tipo de banco relacional. Sendo assim, pela simplicidade, optei por escrever os artigos diretamente em aquivos textos convencionais.

Para a markup escolhi utilizar o [Markdown](http://daringfireball.net/projects/markdown/), escolha também movida principalmente pela sua simplicidade, já que posso escrever os posts utilizando os mesmos editores que uso para codificar. Além disso, ele é um formato muito flexível, onde é possível, por exemplo, utilizar _HTML_ puro no meio do texto quando necessário.

E claro, com esse _setup_ eu sei que não preciso estar conectado na internet para poder escrever, que foi um pré-requisito para mim desde o início.

## Sinatra

Não é porque eu não queria usar uma _blog engine_ pronta, que eu queria implementar todo o [protocolo http](http://www.w3.org/Protocols/rfc2616/rfc2616.html) também. Por outro lado, eu não estava muito afim de usar um framework tão completo quanto o [Rails](http://rubyonrails.org). Sendo assim, acabei optando pelo [Sinatra](http://www.sinatrarb.com/) pela sua simplicidade e elegância, afinal, é muito legal ver um blog implementado em algumas linhas de código. Claro que essa "simplicidade" tem seus _drawbacks_, já que diferente de um Rails, você não tem muitas _coisas prontas_. Por exemplo: eu adoro [Sass](http://sass-lang.com/) e [CoffeeScript](http://coffeescript.org/), e no Sinatra você não tem um _asset pipeline_ (apesar de existir algumas gems que fornecem esse tipo de coisa, mas não me interessaram de primeiro momento). Por conta disso, um dos primeiros problemas que tive foi arrumar uma maneira de compilar essas linguagens no _sinatra_.

## Sass e CoffeeScript

Uma das coisas que mais interessantes do _sinatra_ é como é fácil criar "aplicações dentro de aplicações". Através dessa funcionalidade, eu pude criar duas aplicações separadas, uma que cuida do _Sass_ e uma que cuida do _CoffeeScript_. Depois apenas _montei_ essas aplicações na classe principal do blog.

Por exemplo, a aplicação que converte os arquivos escritos em _CoffeeScript_ para _Javascript_ é essa:

```ruby
class CoffeeHandler < Sinatra::Base
  set :views, File.join(File.dirname(__FILE__), "assets", "coffee")

  get "/coffee/:filename.js" do
    coffee params[:filename].to_sym
  end
end
```

Basicamente, essa é uma aplicação _sinatra_ contendo a rota ``/coffee/*.js`, que quanda acessada, busca um arquivo coffeescript no diretório que configurado na linha 2. Note que o Sinatra já provê um helper `coffee` nativamente, mas por ser apenas um _helper_, ele precisa de algum compilador coffeescript para que funcione corretamente. No meu caso, utilizei a gem [coffee-script](https://rubygems.org/gems/coffee-script) para compilar os arquivos em conjunto com o [therubyracer](https://rubygems.org/gems/therubyracer) para instalar um environment _javascript_.

Mas voltando ao código, isso é tudo que foi preciso para _montar_ a aplicação `CoffeeHandler` na classe do meu blog:

```ruby
class Blog < Sinatra::Base
  use CoffeeHandler
end
```

E _voilá_, temos suporte a _CoffeeScript_! Claro que essa implementação não tem nada sofisticado como a pre-compilação que o _asset pipeline_ do _Rails_ fornece. Por hora pelo menos, essa solução está atendendo muito bem.

Para o _Sass_ fiz algo bem semelhante, com a diferença de que como eu estou utilizando o [Compass](http://compass-style.org/), tive que adicionar algumas configurações exclusivas para ele (você pode consultar o arquivo [blog.rb](http://github.com/reu/blog/blog.rb) direto no repositório no Github se desejar conferir a implementação).

## Markdown

Existem várias _gems_ que "compilam" o Markdown em _HTML_, optei por utilizar a [_RedCarpet_](https://github.com/tanoku/redcarpet/) não só pela sua performance, mas principalmente pela facilidade que é customiza-lo. Uma rápida leitura na [sua documentação](https://github.com/tanoku/redcarpet/#and-you-can-even-cook-your-own) pode dar a ideia do quão flexivel e simples de extender ele é. Além disso, ele suporta algumas extensões muito úteis, como por exemplo o _fenced code blocks_ (utilizado no [Github](http://github.com/), que permite escrever blocos de código utilizando três "`" ao invés de quatro espaços), o _~~strikethrough~~_, e o _autolink_.

Para utilizar o _RedCarpet_ na aplicação bastou um simples _helper_:

```ruby
helpers do
  def markdown(text)
    options = {
      :fenced_code_blocks => true,
      :strikethrough => true,
      :autolink => true,
      :hard_wrap => true
    }

    Redcarpet::Markdown.new(Redcarpet::Render::HTML, options).render(text)
  end
end
```

E então podemos usar esse _helper_ nas nossas _views_:

```erb
<div class="post-content">
  <%= markdown post.body %>
</div>
```

## Syntax Highlight

É inevitável que um blog que fala sobre _desenvolvimento_ traga trechos código nos artigos. E por mais que as pessoas vejam _programadores_ como pessoas estranhas que escrevem coisas sem sentido em um terminal verde e preto (a lá [Matrix](http://www.imdb.com/title/tt0133093/) ou [outros](http://www.imdb.com/title/tt0244244/) [filmes](http://www.imdb.com/title/tt0337978/) de _hackers_, onde aparentemente não existem monitores coloridos), na vida real, é excencial utilizar algum esquema de cores para programar.

Assim como as bibliotecas _Markdown_, [existem](http://pygments.org/) [várias](http://coderay.rubychan.de/) [opções](http://ultraviolet.rubyforge.org/), tanto _server side_ quanto no _[client side](http://softwaremaniacs.org/soft/highlight/en/)_ para tornar trechos de código tão bonitos quanto em qualquer _IDE_. O problema, é que cada uma dessas bibliotecas tem seus poréns, e escolher qual delas se encaixa melhor em cada caso pode ser um trabalho tedioso o maçante. Existem até mesmo dois [Railscasts](http://railscasts.com) falando sobre o assunto, [aqui](http://railscasts.com/episodes/207-syntax-highlighting) e [aqui](http://railscasts.com/episodes/207-syntax-highlighting-revised).

Minha primeira opção foi o _CodeRay_ por ser escrito em _Ruby_ e não precisar compilar nenhuma extensão nativa. Em poucos minutos estava tudo funcionando perfeitamente, porém para minha surpresa, eu não havia reperado que ela não suportava _CoffeeScript_, que era basicamente _a única linguagem que utilizei_ no meu [primeiro artigo](http://rnavarro.com.br/2012/07/13/vetores).

Com essa restrição em mente, sobraram duas opções: o [Pygments](http://pygments.org/) e a [Ultraviolet](http://ultraviolet.rubyforge.org/).

Apesar da _Ultraviolet_ parecer uma opção muito boa, acabei optando pela Pygments por ser a mais utilizada mundo a fora. Agora, é _claro_ que essa decisão também teve seus problemas. Na minha máquina de desenvolvimento, tudo rodou perfeitamente, mas infelizmente no [Heroku](http://heroku.com) (o serviço que uso para hospedar o blog), a biblioteca _RubyPython_ (nome bem descritivo) se recusava a funcionar corretamente. Após alguns _googles_, deu pra concluir que era um problema um tanto comum, mas ainda sem nenhuma solução concreta. Por sorte, o _Pygments_ oferece uma [API HTTP](http://pygments.appspot.com/) (how cool is that?), que serviu como um _fallback_ até que o _RubyPython_ esteja funcional no Heroku.

Com tudo isso pronto, bastava agora transformar os trechos de código em texo puro pelo html gerado pelo _Pygments_. Uma maneira muito comum de fazer isso é usando um _Rack Middleware_ que substitui todos os trechos com o markup \<code\> ou \<pre\> da resposta HTTP pelo _output_ do _Pygments_. Por outro lado, como eu estava utilizando o _RedCloth_, preferi apenas sobrescrever o método que trata a estilização de blocos de código do _Markdown_ para utilizar o _Pygments_. A implementação ficou assim:

```ruby
class MarkdownRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    begin
      Pygments.highlight code, :lexer => language, :options => { :encoding => "utf-8" }
    rescue LoadError, StandardError
      # Post to the Python HTTP API in case we have an error with the Python extensions
      Net::HTTP.post_form(URI.parse("http://pygments.appspot.com/"), "code" => code, "lang" => language).body
    end
  end
end
```

E claro, foi preciso uma pequena alteração no helper `markdown` para que ele utilizasse o novo _renderizador_ para converter o _markdown_:

```ruby
helpers do
  def markdown(text)
    options = {
      :fenced_code_blocks => true,
      :strikethrough => true,
      :autolink => true,
      :hard_wrap => true
    }

    # Using the custom MarkdownRenderer we just created
    Redcarpet::Markdown.new(MarkdownRenderer, options).render(text)
  end
end
```

## Cache

Como a nova _stack Cedar_ do Heroku não disponibiliza mais o [Varnish](https://www.varnish-cache.org/) na frente da aplicação, foi necessário utilizar outra solução para permitir _caches_ HTTP. 

A opção mais óbvia foi o excelente [Rack Cache](http://rtomayko.github.com/rack-cache/). Configura-lo no entanto pode não ser óbvio, já que por padrão ele armazena o _cache_ em memória, o que não é muito útil no Heroku, já que a aplicação normalmente é reiniciada várias vezes, além disso não é possível escrever nada no _filesystem_ (exceto pela pasta _tmp_, que é apagada quando aplicação é reiniciada, tornando inviável para armazenar os _caches_). Por conta disso, decidi utilizar o [memcache](http://memcached.org/).

```ruby
configure :production do
  # Using 'dalli' as a MemCache client
  memcache_client = Dalli::Client.new ENV["MEMCACHE_URL"],
                                      :username => ENV["MEMCACHE_USERNAME"],
                                      :password => ENV["MEMCACHE_PASSWORD"]

  use Rack::Cache, :entitystore => memcache_client, :metastore => memcache_client
end
```

Se quiser entender exatamente o que são o `entitystore` e o `metastore`, acesse a [documentação do _Rack Cache_](http://rtomayko.github.com/rack-cache/storage.html).

## Visual

Como qualquer programador, tenho uma grande dificuldade em fazer designs bonitos. Por conta disso, resolvi partir para a simplicidade. Claro que é excencial ter um conhecimento básico em tipografia, mas, felizmente isso é algo _técnico_ e não _artístico_, ou seja, é possível aprender tipografia facilmente, mas não é possível _aprender_ arte tão fácil assim. Um ótimo livro que li recentemente que fala, não só de tipografia, mas de assuntos diversos de _design_ para WEB é o [Bootstraping Design](http://bootstrappingdesign.com/).

Claro, é importante dar os créditos ao _CloudHead_, já que o visual em si foi _muito_ baseado no template _[Dorothy](http://cloudhead.io/log)_ feito por ele.

# Concluindo

Por incrível que pareça, é possível aprender muito fazendo coisas aparentemente triviais (fazer um blog usando _Ruby_ ou _Rails_ é quase que uma piada). Apesar de eu ter experiência com todas as tecnologias citadas aqui, nunca precisei configurar de fato o _Pygments_ (ou faze-lo funcionar no Heroku), ou mesmo compilar _Sass_ ou _CoffeeScript_ sem a ajuda do _Rails_. Claro que são coisas extremamente simples, mas mesmo assim, é conhecimento.

Se tiver alguma curiosidade em outros detalhes da implementação desse blog, basta acessar seu [repositório no Github](http://github.com/reu/blog).
