title: Codificando meu próprio blog
author: Rodrigo Navarro
date: 2012-07-14

_Engines_ de blog devem ser uma das coisas mais populares da internet. Até mesmo quem não trabalha com desenvolvimento já deve ter ouvido falar do [Wordpress](http://wordpress.com/) por exemplo. Além disso, existem também diversos serviços de ótima qualidade que permite qualquer um começar o seu blog em minutos. E claro que não acaba por aí, existem _muitos_ projetos de ótima qualidade disponíveis gratuitamente e com código aberto, como o próprio Wordpress, o [Movable Type](http://www.movabletype.org/), [Octpress](http://octopress.org/docs/), [Typo](http://typosphere.org), e a lista vai longe. Eu, por exemplo trabalho muito com _Ruby_, que é uma linguagem que ficou muito famosa por conta do _Rails_, que por sua vez teve grande parte da sua fama pelo vídeo do "Programe seu blog em 15 minutos", ou seja, opções com certeza não faltam.

E no meio de tantas opções de qualidade já prontas, por que alguém iria querer "reinventar a roda" e escrever sua própria _engine de blog_? Cada um que já fez isso tem sua própria resposta, mas para mim, creio que foi pelo puro prazer de programar, e claro, é muito legal quando você tem a oportunidade de fazer as coisas do seu jeito, com as exatas funcionalidades que você deseja.

Nesse artigo irei mostrar _como_ fiz para montar esse blog, bem como algumas coisas legais que aprendi nesse processo.

# Motivações

A maior parte dos blogs opensource fornecem coisas muito legais como persistência, cache, editores html super sofisticados, etc. Eu particularmente não vejo necessidade de guardar os posts em algum tipo de banco relacional, e nem mesmo de editores html. Por esse motivo, optei por escrever os artigos diratemente em aquivos textos convencionais.

Para o markup, escolhi o [markdown](http://daringfireball.net/projects/markdown/), também pela sua simplicidade, já que posso escrever os posts utilizando os mesmos editores que uso para codificar. Além disso, o markdown é um formato muito flexível, posso, por exemplo, utilizar html no meio dele quando necessário. É unir o útil ao agradável.

E claro, com esse _setup_ eu sei que não preciso estar conectado na internet para poder escrever, que foi um pré-requisito para mim desde o início.

# Sinatra

Não é porque eu não queria usar uma _blog engine_ pronta, que eu queria implementar todo o [protocolo http](http://www.w3.org/Protocols/rfc2616/rfc2616.html) também. Por outro lado, eu não estava muito afim de usar um framework tão completo quanto o [Rails](http://rubyonrails.org). Sendo assim, acabei optando pelo [Sinatra](http://www.sinatrarb.com/) pela sua simplicidade e elegância, afinal, é muito legal ver um blog implementado em algumas linhas de código. Claro que essa "simplicidade" tem seus _drawbacks_, já que diferente de um Rails, você não tem muitas _coisas prontas_. Por exemplo: eu adoro [Sasss](http://sass-lang.com/) e [CoffeeScript](http://coffeescript.org/), e no Sinatra você não tem um _asset pipeline_ (apesar de existir algumas gems que fornecem esse tipo de coisa, mas não me interessou também). Por conta disso, um dos primeiros problemas que tive foi arrumar uma maneira de compilar essas linguagens no sinatra.

## Modularizando o Sinatra

Um das coisas que mais achei legais no sinatra é como é fácil criar "módulos". Esses módulos são como aplicações seperadas, que você pode "juntar" facilmente. Sendo assim, criei um módulo para o Sass e um para o Coffeescript, e depois apenas _montei_ esses módulos na classe principal do blog.

Por exemplo, o módulo que compila os arquivos escritos coffeescripts para javascript é esse:

```ruby
class CoffeeHandler < Sinatra::Base
  set :views, File.join(File.dirname(__FILE__), "assets", "coffee")

  get "/coffee/:filename.js" do
    coffee params[:filename].to_sym
  end
end
```

Basicamente, essa é uma aplicação com a rota ``/coffee/*.js`, que quanda acessada, busca um arquivo coffeescript no diretório que configurado na linha 2. Note que o Sinatra já provê um helper `coffee` nativamente, mas por ser apenas um _helper_, ele precisa de algum compilador coffeescript para que funcione corretamente. No meu caso, utilizei a gem [coffee-script](https://rubygems.org/gems/coffee-script) para compilar os arquivos em conjunto com o [therubyracer](https://rubygems.org/gems/therubyracer) para instalar um environment _javascript_.

Mas voltando ao código, isso é tudo que foi preciso para _montar_ o módulo `CoffeeHandler` na classe do meu blog:

```ruby
class Blog < Sinatra::Base
  use CoffeeHandler
end
```

E _voilá_, temos suporte a CoffeeScript! Claro que essa implementação não tem nada sofisticado como a pre-compilação que o _asset pipeline_ do _Rails_ fornece, mas para o meu caso, está atendendo muito bem por hora.

Para o Sass eu fiz algo bem semelhante. A diferença foi que, como eu estou utilizando o [Compass](http://compass-style.org/), eu tive que adicionar algumas configurações exclusivas para ele. De qualquer forma, tudo segue a mesma ideia utilizada na compilação do _CoffeeScript_ ([você pode acessar o arquivo blog.rb](http://github.com/reu/blog/blog.rb) se quiser ver como ficou a implementação).
