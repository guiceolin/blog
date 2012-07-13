title: Vetores
author: Rodrigo Navarro
date: 2012-07-13

_Engines físicas_ estão em alta. Com apenas um _google_, podemos facilmente encontrar bibliotecas que nos permitem criar simulações físicas extremamente avançadas. É impossível não se maravilhar enquanto navega pelas dezenas de exemplos dos mais variados casos que essas bibliotecas exibem, e o melhor: além de terem suporte a uma gigantesca variedade de linguagens, grande parte delas estão disponíveis gratuitamente, e na maior parte das vezes, com o código fonte aberto. É como se todos os nossos problemas envolvendo física estivessem resolvidos!

Quem dera...

Infelizmente, toda a empolgação acaba no primeiro projeto real que vamos fazer usando qualquer uma dessas bibliotecas. É normal pensar: "mas é só alterar um pouco esse exemplo, e depois pegar esse outro pedaço de código do _Stackoverflow_, e então..." ... e então... você vai notar que nada vai funcionar do jeito como você imaginou. O exemplo que antes funcionava tão perfeitamente, não é tão simples de ser adaptado para o que têm em sua mente.

O que não notamos de primeiro momento, é que apesar dessas _engines_ trazerem muitas _coisas prontas_, elas também trazem um alto nível de complexidade, e não só a nível de código, mas principalmente a nível de _conceito_. Muitas vezes utilizar uma dessas bibliotecas sem a base técnica necessária pode mais atrapalhar do que ajudar. Por exemplo, sem um conhecimento de vetores e trignometria nós não seríamos sequer capazes de _realmente_ compreender a documentação básica de qualquer uma delas. Por esse motivo, se você quer trabalhar com projetos que envolvam física, é _essencial_ conhecer esses conceitos básicos __isolados de qualquer tipo de biblioteca ou abstração__. Essa base é tão importante que você irá notar que várias (na verdade, mais do que você imagina) das funcionalidades que essas _engines físicas_ fornecem, podem ser implementadas _do zero_ sem muitas dificuldades.

# A base de tudo

Se existe algo que serve base para qualquer simulação física, essa base é o _vetor_. Qualquer _engine_ ou artigo sobre o assunto não só fará um uso extenso deles, como também assumirá um prévio conhecimento em cálculos vetoriais. Agora, é preciso deixar claro que quando eu digo vetores eu _não_ estou falando de vetores como coleção de valores (os _arrays_), ou de _desenhos vetoriais_. Na verdade, __vetor__ tem várias definições, e a que iremos ver nesse artigo é (tirado da wikipedia):

> Um conjunto de elementos geométricos, denominados segmentos de reta orientados, que possuem todos a mesma intensidade (denominada norma ou módulo), mesma direção e mesmo sentido.

Se é a primeira vez que você se depara com o assunto, essa definição provavelmente mais atrapalhou do que ajudou. Mas basicamente, vetor é uma _coleção de valores que descrevem uma posição relativa num espaço_.

<p style="text-align: center">
  <img alt="Vetor indo do ponto a ao ponto b" src="/images/vector-definition.png" />
</p>

Agora antes de entender exatamente _o que_ são vetores, é interessante entender o _porquê_ eles são tão importantes para nossas simulações físicas. Para isso, nada melhor que um exemplo prático, que em um primeiro momento será implementado da maneira mais simplista possível (sem o uso de vetores), e posteriormente utilizando vetores.

## Sobre os exemplos

Todos os códigos serão demonstrados usando [Coffeescript](http://coffeescript.org/). Se você ainda não conhece essa linguagem, vale uma rápida consulta em sua [documentação](http://coffeescript.org/#overview) para se familiarizar com a sintaxe. Basicamente é uma forma ~~menos sofrida~~ mais elegante de se escrever Javascript.

Para a demonstração gráfica dos exemplos iremos utilizar a [API _canvas_ do HTML5](http://dev.w3.org/html5/2dcontext/), que mesmo sendo uma tecnologia relativamente recente, existe [muito](http://diveintohtml5.info/canvas.html) [material](https://developer.mozilla.org/en/Canvas_tutorial/) [disponível](http://dev.opera.com/articles/view/html-5-canvas-the-basics/) para consulta.

Por fim, muitos dos códigos exibidos na página serão uma versão um pouco simplificada da implementação em si, escondendo, por exemplo, os _detalhes_ da renderização dos objetos na tela ou tratamento de eventos (como movimento de mouse, clicks, etc). De qualquer forma, você pode consultar o código completo de todos os exemplos [nesse repositório no github](http://github.com/reu/blog/assets/coffee).

## O _hello world_ das simulações físicas

<script type="text/javascript" src="/coffee/request_animation_frame.js"></script>
<script type="text/javascript" src="/vector.js"></script>

<script type="text/javascript" src="/coffee/bouncing_balls_without_vectors.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var firstExample = new FirstExample(190, 190);
    firstExample.start();
  });
</script>

<div id="first_example"></div>

Como o primeiro exemplo, vamos criar um dos cenário mais comuns em tutoriais de física: um círculo que rebate na tela. A estrutura do programa é bem simples: um loop infinito que a irá alterar a posição do círculo a cada iteração. Como esse loop roda 60 vezes por segundo, o que iremos ter é uma _ilusão de movimento_, já que a cada iteração (também chamado de _frame_) o círculo estará em uma nova posição.

```coffeescript
class Ball
  constructor: (@x, @y) ->
    # Setting some random velocities here
    @xVelocity = 3
    @yVelocity = 1.5

    # The size of the ball
    @radius = 10

  # Increment the ball position based on its current velocity
  update: ->
    @x += xVelocity
    @y += yVelocity

  # Inverts the ball velocity when it hits any of the bounds of the canvas
  checkBounds: (area) ->
    # Inverting the x velocity when the ball touches the left or right side of the screen
    @xVelocity *= -1 if @x > area.width  or @x < 0

    # Inverting the y velocity when the ball touches the up or down side of the screen
    @yVelocity *= -1 if @y > area.height or @y < 0

  # Draw the ball on the screen
  draw: (context) ->
    context.fillCircle @x, @y, @radius

# Creating the ball instance and positioning it on a random position on the screen
ball = new Ball(10, 10)

# Let's use the HTML5 canvas to render the example.
canvas  = getElementById("example01")
context = canvas.getContext("2d")

infiniteLoop =->
  ball.update()
  ball.checkBounds(canvas)
  ball.draw(context)

# Calls the infiniteLoop function 60 times per second
setInterval 1000 / 60, infiniteLoop
# Note we are using setInterval here for simplicity's sake, as it is not the recommended way.
# You should always use requestAnimationFrame API for canvas drawing. Check out the example file
# for more information on how to use it.
```

Apesar de simples, o exemplo é interessante porque deixa bem evidente dois conceitos cruciais que servirão de base para __todas__ as simulações físicas que envolvam movimento:

* __Posição__: as propriedades `x` e `y` do círculo
* __Velocidade__: a quantidade de pixels que a _posição_ será alterada a cada iteração do loop, representadas pelas variáveis `xVelocity` e `yVelocity`

E claro que a pederiamos refinar a simulação adicionando outras propriedades físicas, como por exemplo:

* __Aceleração__: quantidade de variação de _velocidade_ a cada iteração. Seria representada por algo como `xAcceletation` e `yAcceleration`
* __Vento__: `xWind` e `yWind`
* __Gravidade__: `xGravity` e `yGravity`
* __Fricção__: `xFriction` e `yFriction`

Agora se pararmos para observar, podemos notar claramente que todas essas propriedades (aceleração, vento, etc) sempre precisam de dois valores para serem representadas: um `x` e um `y`. Isso acontece porque estamos trabalhando num contexto `2D`, se a nossa simulação fosse em `3D`, notaríamos que iríamos precisar de ainda mais um valor, que seria referente ao eixo `z`.

Sabendo-se disso, e se agrupássemos esses dois valores em algum tipo de estrutura, de modo generalizar (e simplificar) as coisas? Afinal, não ficaria mais organizado se ao invés de escrever dessa maneira:

```coffeescript
@x = 4
@y = 8

@xVelocity = 1.5
@yVelocity = 3

@xWind = 0.3
@yWind = 0.01
```

Escrevêssemos dessa?

```coffeescript
@position = new Vector(4, 8)
@velocity = new Vector(1, 3)
@wind     = new Vector(0.3, 0.01)
```

Sim, acabamos de escrever nossos primeiros vetores! Claro que no momento eles não parecem trazer muitas vantagens, mas não se preocupe, isso é só o começo.

## Conhecendo os vetores

Como já vimos no início a definição básica de vetores, podemos resumi-los aqui como a **diferença entre dois pontos** num espaço. Relembrando o que foi demonstrado no exemplo anterior, nós estamos alterando a posição do círculo a cada iteração por um número de pixels horizontais e um número de pixels verticais (foi o que chamamos de **velocidade**), que, matematicamente se traduz para:

`position = position + velocity`

Observando a fórmula acima podemos então afirmar que a __velocidade é um vetor__, já que ela descreve a diferença entre dois pontos: o ponto atual do objeto, e o ponto que o objeto vai estar após a iteração.

<p style="text-align: center">
  <img alt="Vetor de velocidade" src="/images/vector-velocity.png" />
</p>

Mas agora você pode se perguntar, e a __posição__? É também considerada um vetor? Afinal, apesar de ela também ter as propriedades `x` e `y`, ela não descreve a diferença entre dois pontos, ela apenas especifica uma coordenada. A resposta para essa pergunta é bastante debatida, tanto que algumas linguagens (como por exemplo o _Java_) utilizam classes distintas para especificar uma _coordenada_ e um _vetor_. Em contra partida, a maior parte das linguagens e _engines físicas_ simplificam esse caso e __tratam essa coordenada também como um vetor__, já que uma outra forma descrever a posição é como a __diferença entre a origem para a sua posição__, o que elimina "burocracia" de ter duas classes que representam a mesma coisa só que com nomes diferentes. Para simplificar, vamos também tratar uma coordenada como um vetor.

<p style="text-align: center">
  <img alt="Vetor de posição" src="/images/vector-coordinate.png" />
</p>

Mas voltando ao exemplo, tínhamos:

```coffeescript
position = x, y
velocity = xVelocity, yVelocity
```

Vamos criar nossa classe `Vector` que irá armazenar esses valores:

```coffeescript
class Vector
  constructor: (x, y) ->
    @x = x
    @y = y
```

E reescrever a classe `Ball` para tratar sua posição e sua velocidade como dois vetores:

```coffeescript
class Ball
  constructor: (x, y) ->
    @position = new Vector(x, y)
    @velocity = new Vector(3, 1.5)
```

Com isso, podemos finalmente implementar nosso algorítimo de movimento usando vetores! Apenas relembrando, na implementação original nós tínhamos:

```coffeescript
@x += xVelocity
@y += yVelocity
```

E o que gostaríamos de fazer agora seria:

```coffeescript
@position = @position + @velocity
```

Infelizmente como estamos trabalhado com _Javascript_ nos exemplos, você já deve saber que essa sintaxe não é permitida pela linguagem, já que não podemos implementar uma função de soma de dois objetos da classe `Vector` utilizando o simbolo `+` (na verdade, a única linguagem que conheço que permitiria tal sintaxe é o _Ruby_). Resumindo, o _Javascript_ não sabe como somar dois vetores como ele sabe como somar dois inteiros ou até mesmo "somar" duas _strings_ utilizando o operador `+`, logo, a única opção que nos resta é utilizar uma sintaxe um pouco diferente para esse caso.

### Somando vetores

Já temos uma primeira versão da nossa classe `Vector` que basicamente é uma estrutura que possui as propriedades `x` e `y`. Agora teremos que implementar um método nessa classe que irá somar essas propriedades com as propriedades de um outro vetor. Mas antes, é importante entender exatamente o que significa somar dois vetores. Para isso, vamos primeiro nos familiarizar com algumas notações matemáticas que serão usadas daqui para frente.

<img src="/images/vector-notation.png" style="display: block; float: right; margin-right: 30px" />

Vetores normalmente são representados com as letras em negrito e/ou com uma seta em cima do seu nome. Para facilitar a escrita, vamos utilizar apenas as letras em negrito para diferenciar um __vetor__ de um escalar (escalar se refere a um valor inteiro ou decimal, como as propriedades `x` e `y`).

Com isso claro, vamos retomar no caso da soma. Já sabemos que cada vetor tem duas propriedades: um `x` e um `y`. Para somar um vetor com outro, basta somar as propriedades `x` e `y` de ambos.

Para ficar mais claro, supondo que temos os vetores __a__ e __b__:

__a__ = (3, 4)  
__b__ = (6, 1)

Podemos dizer que:

__c__ = __a__ + __b__

É equivalente a:

__c__<sub>x</sub> = __a__<sub>x</sub> + __b__<sub>x</sub>  
__c__<sub>y</sub> = __a__<sub>y</sub> + __b__<sub>y</sub>

Portanto:

__c__<sub>x</sub> = 3 + 6  
__c__<sub>y</sub> = 4 + 1

E portanto:

__c__ = (9, 5)

Extremamente simples, não? Vamos então implementar o método `add` na nossa classe `Vector`:

```coffeescript
class Vector
  constructor: (@x, @y) ->

  add: (vector) ->
    @x += vector.x
    @y += vector.y
```

E finalmente terminar a refatoração do nosso exemplo:

```coffeescript
class Ball
  constructor: (x, y) ->
    @position = new Vector x, y
    @velocity = new Vector 3, 1.5
    @radius = 10

  update: ->
    # Incrementing the ball position by adding the velocity vector to the position vector
    @position.add(@velocity)

  checkBounds: (area) ->
    # Of course we can access the x and y properties of a vector directly
    @velocity.x *= -1 if @position.x > area.width  or @position.x < 0
    @velocity.y *= -1 if @position.y > area.height or @position.y < 0

  draw: (context) ->
    # As the canvas API doesn't support passing vectors as arguments, so we must inform the x and y scalars
    context.fillCircle @position.x, @position.y, @radius
```

Você deve estar nesse momento pensando: "espere aí, é só isso? Fizemos tudo isso e o código não mudou quase nada!". De fato, utilizar vetores não irá magicamente fazer que seus programas simulem perfeitamente conceitos físicos. É importante entender que isso ainda não é o suficiente para que você compreenda o _poder_ de organizar (e pensar) usando vetores. Nos próximos exemplos, vamos abordar algumas situações mais complexas que talvez deixe isso mais claro, mas por hora, vamos continuar com alguns outros conceitos básicos.

### Subtraindo, multiplicando e dividindo vetores

Como você já imaginava, soma não é a única operação realizada com vetores. Na verdade, além das básicas (soma, subtração, divisão e multiplicação) existem ainda diversas outras (veja por exemplo, os métodos da classe [Vector2d](http://docs.oracle.com/cd/E17802_01/j2se/javase/technologies/desktop/java3d/forDevelopers/j3dapi/javax/vecmath/Vector2d.html) do java).

Começando pela _subtração_, que como você já deve imaginar, funciona da mesma maneira que a soma, só iremos (obviamente) trocar o operador:

```coffeescript
class Vector
  sub: (vector) ->
    @x -= vector.x
    @y -= vector.y
```

Agora multiplicação é um pouco diferente. Nós não multiplicamos um _vetor_ por outro, como fazemos com a soma e subtração. Nós multiplicamos um vetor por um _escalar_. Sendo assim, em muitas linguagens você não encontrará um método `multiply`, você irá encontrar um método chamado `scale`, já que o que a multiplicação (e a divisão também) faz é escalar um vetor. Podemos dizer, por exemplo que queremos _dobrar_ ou _triplicar_ o tamanho de um vetor, bem como podemos dizer que queremos reduzi-lo pela metade.

Novamente, supondo que temos um vetor __a__:

__a__ = (-7, -3)  

Vamos criar um vetor __b__ __três vezes maior__ que o __a__:

__b__ = __a__ * 3

Isso é equivalente a:

__b__<sub>x</sub> = -7 * 3  
__b__<sub>y</sub> = -3 * 3

Portanto:

__b__ = (-21, -9)

<p style="text-align: center">
  <img alt="Vetor sendo escalado" src="/images/vector-multiplication.png" />
</p>

Sendo assim, a implementação do nosso método:

```coffeescript
class Vector
  mult: (scalar) ->
    @x *= scalar
    @y *= scalar
```

E claro, a divisão funciona da mesma maneira:

```coffeescript
class Vector
  div: (scalar) ->
    @x /= scalar
    @y /= scalar
```

Agora uma coisa importante que precisamos notar: todos os métodos que implementamos __alteram o estado__ do vetor em si. Então, é preciso tomar muito cuidado, porque você pode ficar tentado a fazer esse tipo de coisa:

```coffeescript
a = new Vector(5, 5)
b = new Vector(2, 2)
c = a.sub(b)
```

Deve ficar claro que isso __não irá funcionar como o esperado__. O que esse código faz na realidade é alterar o valor do vetor __a__ para (3, 3), e não retornar um novo vetor com esse valor para ser atribuído a __c__. Sendo assim, em vários casos é útil poder executar uma operação e retornar o resultado em outro vetor, para isso, vamos ter que criar método _estáticos_ na nossa classe `Vector` com nossas já conhecidas operações básicas.

```coffeescript
class Vector
  @add: (v1, v2) ->
    new Vector v1.x + v2.x, v1.y + v2.y

  @sub: (v1, v2) ->
    new Vector v1.x - v2.x, v1.y - v2.y

  @mult: (vector, scalar) ->
    new Vector vector.x * scalar, vector.y * scalar, vector.z * scalar

  @div: (vector, scalar) ->
    new Vector vector.x / scalar, vector.y / scalar, vector.z / scalar
```

Agora é possível fazer a operação acima, só que de uma maneira um pouco diferente:

```coffeescript
a = new Vector(5, 5)
b = new Vector(2, 2)
c = Vector.sub(a, b)
```
Com isso concluímos as operações básicas. Mas ainda não é tudo (nem perto disso). Na verdade, conhecer esses conceitos abrem portas para entender outras importantes propriedades e funções de um vetor.

### Magnitude

Como ficou claro na multiplicação e divisão, sabemos que é possível aumentar e diminuir vetores facilmente. Mas e se quisermos saber qual o __tamanho__ exato de um vetor? Como você já deve ter notado, todo o vetor se parece com um triangulo retângulo quando juntarmos seus pontos:

<p style="text-align: center">
  <img alt="Vetor de posição" src="/images/vector-length.png" />
</p>

Acontece que ele não só _se parece_ com um triângulo, um vetor _é_ triângulo retângulo, e como nós já temos os dois lados do triângulo (os catetos), basta utilizarmos o [teorema de Pitagoras](http://pt.wikipedia.org/wiki/Pit%C3%A1goras) para encontrar a _Hipotenusa_ (que representa o tamanho de qualquer vetor). 

<p style="text-align: center">
  <img alt="Vetor de posição" src="/images/vector-triangle.png" />
</p>

A fórmula, caso alguém tenha faltado das aulas de trigonometria do colegial, é super simples:

> A soma dos quadrados dos catetos é igual ao quadrado da hipotenusa.

<p style="text-align: center">
  <img alt="Teorema de pitágoras" src="/images/vector-pythagorean-theorem.gif" />
</p>

```coffeescript
class Vector
  magnitude: ->
    Math.sqrt @x * @x, @y * @y
```

### Normalização

Conhecendo o conceito de _magnitude_ podemos finalmente entender um dos conceitos mais importantes em cálculos vetoriais: a normalização.

Agora, _normalização_ é algo já bem conhecido e aplicado em várias situações. O processo consiste em tornar um valor "normal", ou "padrão". No nosso caso, um vetor "padrão" (chamado de __vetor unitário__) é um vetor que tenha uma magnitude de _valor 1_. Ou seja, pra normalizar nosso vetor, basta reduzirmos (ou aumentarmos em alguns casos) seu _tamanho_ para 1. A parte interessante disso é que como só seu tamanho é alterado, sua __direção é mantida intacta__ (iremos entender o porquê isso é importante em breve).

E como podemos ajustar o tamanho de um vetor para exatamente `1`? Simples, basta dividirmos cada uma de suas propriedades (no nosso caso, os valores de x e y) pela magnitude do vetor:

<p style="text-align: center">
  <img alt="Vetor de posição" src="/images/vector-normalization.png" />
</p>

A implementação fica simples, já que os métodos para divisão e magnitude já estão disponíveis: 

```coffeescript
class Vector
  normalize: ->
    @div(@magnitude())
```

## Programando movimento com vetores

Até agora só vimos os conceitos básicos de vetores mas não fizemos nada prático que realmente justifique o uso deles, logo, é possível que eles continuem parecendo pouco úteis. A verdade é que leva um tempo para _realmente_ perceber o quanto importante é saber utiliza-los. Para tentar "acelerar" esse processo, vamos explorar alguns casos um pouco mais complexos, onde a utilização correta de vetores pode tornar a implementação _muito_ mais simples tanto de escrever como de compreender.

Para começar, vamos ver algo muito utilizado em qualquer simulação física: __aceleração__.

Como já vimos, __velocidade__ é a quantidade de variação de posição. A __aceleração__ é a quantidade de variação de __velocidade__. Então podemos dizer que a _aceleração_ afeta a _velocidade_ e essa por sua vez afeta a _posição_. 

`velocity = velocity + acceleration`   
`position = position + velocity`

Que traduzindo para código, seria:

```coffeescript
velocity.add(acceleration)
position.add(velocity)
```

Como é possível notar, podemos alterar tanto a posição e a velocidade através da aceleração, com isso, nunca será necessário alterar os valores de velocidade e posição diretamente (apenas, é claro, no processo de inicialização). Essa "ideia" de não alterar diretamente os valores de velocidade e posição, por exemplo, é muito comum em qualquer _engine_ física, por isso quando quisermos fazer um objeto se mover pela tela, temos que pensar em algorítimos para manipular sua _aceleração_. Para ficar claro, vamos ver alguns algorítimos bastante conhecidos:

1. Aceleração constante
2. Aceleração aleatória
3. Aceleração até um ponto específico

### Aceleração constante

Sem dúvida o algoritmo mais simples e básico de aceleração, onde o objeto irá ganhar velocidade gradualmente. Para isso, vamos voltar ao nosso exemplo dos círculos:

```coffeescript
class Ball
  constructor: (x, y) ->
    @position = new Vector x, y

    # Let's start with no velocity at all
    @velocity = new Vector 0, 0

    # NEW acceleration property
    @acceleration = new Vector(0.005, 0.01)
```

Podemos notar que por enquanto as únicas modificações feitas foram zerar a velocidade e adicionar uma nova propriedade para a aceleração. Outro ponto bastante importante de se observar é que a aceleração tem valores _muito_ pequenos, isso é necessário já que a cada iteração do nosso _loop_, iremos somar esses valores na velocidade do círculo, e como temos 60 iterações desse loop por segundo, se o valor for alto, o objeto irá ganhar aceleração muito rapidamente, tirando todo o "efeito" que queremos simular.

Mas continuando, agora vamos alterar o método `update` para adicionar aceleração a nossa velocidade:

```coffeescript
update: ->
  @velocity.add @acceleration
  @position.add @velocity
```

Tudo irá funcionar perfeitamente com um porém: a velocidade nesse caso tende ao infinito, ou seja, se deixarmos o exemplo rodando por algum tempo, a velocidade acumulada será tão grande que não será mais possível ver o círculo na tela (de tão rápido que ele irá se mover!). Com isso, precisamos pensar em uma maneira de _limitar_ nossa velocidade. Lembrando que como a __velocidade__ é um vetor, podemos dizer então que se conseguissemos _limitar o tamanho desse vetor_, iriamos conseguir limitar a velocidade máxima.

Para isso, basta checarmos se a magnitude (lembrando que magnitude é o _tamanho_ do vetor) é maior que um certo número (um _escalar_), caso seja nada é feito, mas caso não seja, o que iremos fazer é _normalizar_ o vetor (ajustando então, seu tamanho para `1`) e depois multiplica-lo pelo tamanho máximo informado.

```coffeescript
class Vector
  limit: (max) ->
    if @mag() > max
      do @normalize
      @mult(max)
```

Com isso, podemos agora _limitar_ nossa velocidade facilmente:

```coffeescript
update: ->
  @velocity.add @acceleration
  @velocity.limit 15 # Let's not allow a velocity greater than 15
  @position.add @velocity
```

Uma última modificação que faremos para que seja possível visualizar melhor o efeito de aceleração constante será que ao invés dos círculos rebaterem nas bordas, iremos "transporta-los" para o lado inverso (da mesma forma como é feito jogo [Asteroids](http://en.wikipedia.org/wiki/Asteroids_(video_game\)) por exemplo). Para isso, basta alterarmos o método `checkBounds`:

```coffeescript
checkBounds: (area) ->
  @position.x = 0           if @position.x > area.width 
  @position.x = area.width  if @position.x < 0

  @position.y = 0           if @position.y > area.height
  @position.y = area.height if @position.y < 0
```

E o resultado podemos ver no seguinte exemplo:

<script type="text/javascript" src="/coffee/constant_acceleration.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var example = new BallWithConstantAcceleration("#constant_acceleration", 900, 290);
    example.start();
  });
</script>

<div id="constant_acceleration"></div>

### Aceleração aleatória



Vamos usar o exemplo anterior como base e modifica-lo para que ele gere uma aceleração diferente a cada iteração do nosso _loop_. Mas antes, para simplificar a implementação, vamos uma função que retorna um número aleatório dentro de um range, já que o javascript não fornece algo do tipo nativamente:

```coffeescript
random = (min, max) -> Math.random() * (max - min) + min
```

Com isso, vamos agora redefinir o método `update` e gerar uma aceleração aleatória a cada _frame_:

```coffeescript
update: ->
  @acceleration = new Vector random(-1, 1), random(-1, 1)
  @acceleration.normalize()

  @velocity.add @acceleration
  @velocity.limit 15
  @position.add @velocity
```

Apesar de não ser necessário normalizar a aceleração, isso torna a implementação mais flexível para atender dois casos comuns:

* escalar a aceleração para um valor constante

```coffeescript
@acceleration = new Vector random(-1, 1), random(-1, 1)
@acceleration.normalize()
@acceleration.div(2)
```

* escalar a aceleração para um valor aleatório

```coffeescript
@acceleration = new Vector random(-1, 1), random(-1, 1)
@acceleration.normalize()
@acceleration.div(random(1, 2))
```

E o resultado dos dois casos:

<script type="text/javascript" src="/coffee/random_acceleration.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var example1 = new RandomDirection("#random_direction", 440, 200);
    var example2 = new RandomAcceleration("#random_acceleration", 440, 200);

    example1.start();
    example2.start();
  });
</script>

<div id="random_direction" style="float: left"></div>
<div id="random_acceleration" style="float: right"></div>
<div style="clear: both"></div>

Esse exemplo é de extrema importância pois mostra que aceleração não é apenas usada para fazer com que objetos acelerem ou desacelerem, mas que também pode ser usada para _qualquer_ mudança de velocidade, seja essa uma mudança de magnitude (que é o que faz um objeto andar mais rápido ou mais devagar), ou uma __mudança de direção__.

### Aceleração em direção a um ponto

Como último exemplo, vamos implementar a aceleração direcionada a um ponto. Esse ponto, pode ser qualquer coisa, seja ele um outro objeto, ou, como no nosso caso, o _mouse_. Sendo assim, teremos que implementar um algorítimo que acelere em _direção ao ponteiro do mouse_.

Para esse tipo de simulação nós sempre iremos precisar calcular duas coisas: a __magnitude__ e a __direção__.

Computar a __magnitude__ creio que já está bem claro, já temos o método `magnitude` que retorna esse valor. Agora para a __direção__ precisamos montar um vetor que vai da posição atual do objeto até o ponteiro do mouse (podemos dizer que precisamos de um vetor que _aponta_ para o _mouse_). Para isso, vamos fazer uma simples subtração: vamos pegar o ponto do mouse e subtrair o ponto do objeto.

`direction = mouse - position`

<p style="text-align: center">
  <img alt="Subtração do objeto para a posição do mouse" src="/images/vector-subtraction.png" />
</p>

Traduzindo para nossa linguagem:

```coffeescript
direction = Vector.sub @mouse, @position
```

Com isso criamos nosso vetor `direction`, que irá apontar para o ponteiro do mouse. Agora muito cuidado: se utilizássemos esse vetor como aceleração, nosso objeto iria aparecer no ponteiro do mouse instantaneamente. Talvez isso seja útil em alguma simulação, mas para nosso caso, queremos limitar o quão rápido o nosso objeto irá em direção ao mouse, ou seja, nós queremos limitar a _magnitude_ desse vetor.

Para isso, vamos _normalizar_ o vetor (que lembrando irá manter sua direção, mas irá fixar sua magnitude ao valor `1`) e como ele normalizado podemos facilmente escalar sua magnitude.

```coffeescript
direction = Vector.sub @mouse, @position
direction.normalize()
direction.mult 0.5 # Here we are multiplying the acceleration by 0.5 pixles per frame
```

E sobrescrevendo mais uma vez nosso método `update`:

```coffeescript
update: ->
  direction = Vector.sub @mouse, @position
  direction.normalize()
  direction.mult 0.5

  @acceleration = direction

  @velocity.add @acceleration
  @velocity.limit MAX_SPEED
  @position.add @velocity
```

E temos esse resultado (instanciando vários objetos para um _wow effect!_):

<script type="text/javascript" src="/coffee/acceleration_towards_mouse.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var example = new AccelerationTowardsMouse("#acceleration_towards_mouse", 900, 300);
    example.start();
  });
</script>

<div id="acceleration_towards_mouse"></div>

E nossa implementação completa:

```coffeescript
class Ball
  MAX_SPEED = 10

  constructor: (x, y) ->
    @position = new Vector x, y
    @velocity = new Vector 0, 0
    @radius = 10

  update: (mouse) ->
    direction = Vector.sub mouse, @position
    direction.normalize()
    direction.div 2

    acceleration = direction

    @velocity.add acceleration
    @velocity.limit MAX_SPEED
    @position.add @velocity

  draw: (context) ->
    context.fillCircle @position.x, @position.y, @radius

canvas  = getElementById("canvas")
context = canvas.getContext("2d")

random = (min, max) -> Math.random() * (max - min) + min

balls = []
for index in [1..10]
  balls.push new Ball(random(0, canvas.width), random(0, canvas.height))

mouse = new Vector 0, 0

canvas.addEventListener "mousemove", ->
  mouse.x = event.offsetX
  mouse.y = event.offsetY

infiniteLoop =->
  for ball in balls
    ball.update(mouse)
    ball.draw(context)

setInterval infiniteLoop, 1000 / 60
```

# Fechando

Ainda existem (muitos) outros assuntos que podem ser abordados que utilizam vetores para simular eventos do mundo real. Por exemplo, você deve ter notado, que na nossa última simulação os círculos não "param" quando chegam no mouse, pelo contrário, eles "_passam_" por ele e depois precisam voltar (ficando nesse ciclo infinitamente). Isso acontece porque não estamos limitando a __força__ máxima que o vetor pode acelerar (lembre-se: estamos limitando apenas a _velocidade_). Em futuros artigos, iremos estudar vários dos algorítimos do Crayg Reynolds, e um deles é o [_arrival_](http://www.red3d.com/cwr/steer/Arrival.html), que trata exatamente esse caso: um objeto que acelera até um ponto e desacelera a ponto de parar quando finalmente chega em seu destino.

Outra grande vantagem que ganhamos "quase de graça" quando utilizamos vetores, e que não foi explorada nesse artigo, é a conversão desses cálculos para um "mundo" `3D`. Para isso, bastava inicializar/manipular os vetores utilizando mais um eixo (convencionalmente chamado de eixo `z`). Converter os exemplos mostrados nessa página para suportar uma terceira dimensão é algo trivial, mas que ficará para um próximo artigo.

Por hora, espero que tenha ficado claro algumas das vantagens do uso de vetores em simulações físicas, bem como as propriedades e operações que eles possuem.

### Agradecimentos

A maior parte tanto do conteúdo quanto dos exemplos desse artigo não foram só baseados como transcritos de livros e tutoriais escritos pelo [Daniel Shiffman](http://www.shiffman.net) e pelo [Craig Reynolds](http://www.red3d.com/cwr). Portanto, todos os créditos devem ser dados a eles.

### Opensource

A classe `Vector` que criamos pode ser encontrada para download em seu [próprio repositório no github](http://github.com/reu/vector.js). Além de estar 100% coberta por testes (e ter alguns outros métodos adicionais), ela também dá suporte a vetores `3D`.

Outra biblioteca usada nos exemplos é o [canvas-extensions](https://github.com/reu/canvas-extensions), que _embute_ alguns métodos úteis no `context` do `canvas` do HTML5 (como por exemplo, o método `fillCircle`).
