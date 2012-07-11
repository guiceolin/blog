title: Vetores
author: Rodrigo Navarro

[Reescrever introdução]


# A base de tudo

Se existe algo que serve base para qualquer simulação física, essa base é o _vetor_. Qualquer _engine_ ou artigo sobre o assunto não só fará um uso extenso deles, como também assumirá um prévio conhecimento em cálculos vetoriais. Agora, é preciso deixar claro que quando eu digo vetores eu _não_ estou falando de vetores como coleção de valores (os _arrays_), ou de _desenhos vetoriais_. Na verdade, __vetor__ tem várias definições, e a que iremos ver nesse artigo é (tirado da wikipedia):

> Um conjunto de elementos geométricos, denominados segmentos de reta orientados, que possuem todos a mesma intensidade (denominada norma ou módulo), mesma direção e mesmo sentido.

Se é a primeira vez que você se depara com o assunto, essa definição provavelmente mais atrapalhou do que ajudou. Mas não se preocupe, eles não são tão complicados quanto parecem.

Agora antes de entender exatamente _o que_ são vetores, é interessante entender o _porquê_ eles são tão importantes para nossas simulações físicas. Para isso, nada melhor que um exemplo prático, que em um primeiro momento será implementado da maneira mais simplista possível (sem o uso de vetores), e posteriormente utilizando vetores.

## Sobre os exemplos

Todos os códigos serão demonstrados usando [Coffeescript](http://coffeescript.org/). Se você ainda não conhece essa linguagem, vale uma rápida consulta em sua [documentação](http://coffeescript.org/#overview) para se familiarizar com a sintaxe. Basicamente é uma forma ~~menos sofrida~~ mais elegante de se escrever Javascript.

Mesmo sendo um detalhe que não vai afetar a compreensão dos exemplos, iremos utilizar a [API _canvas_ do HTML5](http://dev.w3.org/html5/2dcontext/) para _renderização_, que apesar de ser uma tecnologia relativamente recente, existe [muito](http://diveintohtml5.info/canvas.html) [material](https://developer.mozilla.org/en/Canvas_tutorial/) [disponível](http://dev.opera.com/articles/view/html-5-canvas-the-basics/) para consulta sobre o assunto.

Além disso, muitos dos códigos exibidos na página serão uma versão um pouco simplificada da implementação em si, escondendo, por exemplo, os _detalhes_ da renderização dos objetos na tela ou tratamento de eventos (como movimento de mouse, clicks, etc). De qualquer forma, você pode consultar o código completo de todos os exemplos [nesse repositório no github](http://github.com/reu/blog/assets/coffee).

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

E claro que a medida que vamos refinando nossas simulações, podemos querer adicionar outras propriedades físicas. Por exemplo:

* __Aceleração__: quantidade de variação de _velocidade_ a cada iteração. Seria representada por algo como `xAcceletation` e `yAcceleration`
* __Vento__: `xWind` e `yWind`
* __Gravidade__: `xGravity` e `yGravity`
* __Fricção__: `xFriction` e `yFriction`

Podemos observar claramente que todas essas propriedades (gravidade, vento, etc) sempre precisam de dois valores para serem representadas: um `x` e um `y`. Isso acontece porque estamos trabalhando num contexto `2D`, se a nossa simulação fosse em `3D`, notaríamos que iríamos precisar de ainda mais um valor, que seria referente ao eixo `z`.

Agora, e se pudéssemos agrupar esses valores em algum tipo de estrutura, de modo simplificar (e generalizar) o processo? Afinal, não ficaria mais organizado se ao invés de escrever dessa maneira:

```coffeescript
@x = 4
@y = 8
@xVelocity = 1.5
@yVelocity = 3
```

Escrevêssemos dessa?

```coffeescript
@position = new Vector(4, 8)
@velocity = new Vector(1, 3)
```

Sim, acabamos de escrever nossos dois primeiros vetores, que até então não parecem trazer muitas vantagens, mas não se preocupe, isso é só o começo.

## Conhecendo os vetores

Vetores são, resumidamente, a **diferença entre dois pontos** num espaço. Relembrando o que foi demonstrado no exemplo anterior, nós estamos alterando a posição do círculo a cada iteração por um número de pixels horizontais e um número de pixels verticais (foi o que chamamos de **velocidade**), que, matematicamente se traduz para:

`position = position + velocity`

Observando a fórmula acima podemos então afirmar que a __velocidade é um vetor__, já que ela descreve a diferença entre dois pontos: o ponto atual do objeto, e o ponto que o objeto vai estar após a iteração.

Mas agora você pode se perguntar, e a __posição__? É também considerada um vetor? Afinal, apesar de ela também ter as propriedades `x` e `y`, ela não descreve a diferença entre dois pontos, ela apenas especifica uma coordenada. A resposta para essa pergunta é um tanto complicada, já que ela é bastante debatido, tanto que algumas linguagens (como por exemplo o _Java_) tem classes distintas para especificar uma _coordenada_ e um _vetor_. Em contra partida, a maior parte das linguagens e _engines físicas_ simplificam esse caso e __tratam essa coordenada também como um vetor__, já que uma outra forma descrever a posição é como a __diferença entre a origem para a sua posição__, o que eliminta a "burocracia" de ter duas classes que representam a mesma coisa só que com nomes diferentes. Para simplificar as coisas, vamos também seguir a segunda opção.

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

Já temos uma primeira versão da nossa classe `Vector` que basicamente é uma estrutura que possui as propriedades `x` e `y`. Agora teremos que implementar um método nessa classe que irá somar essas propriedades com as propriedades de um outro vetor. Mas antes, é importante entender exatamente o que significa somar dois vetores. Para isso, vamos primeiro nos familiarizar com algumas notações matemáticas usadas para representar vetores.

Vetores normalmente são representados com as letras em negrito e/ou com uma seta em cima do seu nome. Para facilitar a escrita, vamos utilizar apenas as letras em negrito para diferenciar um __vetor__ de um escalar (escalar se refere a um valor inteiro ou decimal, como as propriedades `x` e `y`).

Com isso claro, vamos finalmente entender como funciona a soma de vetores. Já sabemos que cada vetor tem duas propriedades: um `x` e um `y`. Para somar um vetor com outro, basta somar as propriedades `x` e `y` de ambos.

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

Agora multiplicação é um pouco diferente. Nós não multiplicamos um _vetor_ por outro, como fazemos com a soma e subtração. Nós multiplicamos um vetor por um _escalar_. Sendo assim, em muitas linguagens você não encontrará um método `multiply`, você irá encontrar um método chamado `scale`, já que o que a multiplicação (e a divisão também) faz é escalar um vetor. Podemos dizer, por exemplo que queremos _dobrar_ ou _triplicar_ o tamanho de um vetor, bem como podemos dizer que queremos reduzir ele pela metade.

[ilustração de um vetor sendo escalado]

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

Como vimos na multiplicação de divisão dos vetores, já sabemos que é possível aumentar-los e diminui-los. Mas e se quisermos saber qual o _tamanho_ exato de um vetor? Como você já deve ter notado, todo o vetor se parece com um triangulo retângulo quando juntarmos seus pontos:

[ilustração de um vetor]

O fato é: ele não só _se parece_ com um triângulo, um vetor _é_ triângulo retângulo. Com isso, vamos voltar a nosso colegial e relembrar do _temorema de Pitagoras_, que utilizaremos para descobrir a hipotenusa do triângulo, já que ela equivale ao _tamanho_ do vetor, ou, no notação mais correta, a __magnitude__.

[ilustração da regra de pytagoras]

Só relembrando, segundo teorema de Pitagoras, a _hipotenusa é a soma dos quadrado dos lados_ de um triângulo retângulo. Logo, a implementação é bem simples:

```coffeescript
class Vector
  magnitude: ->
    Math.sqrt @x * @x, @y * @y
```

### Normalização

Conhecendo o conceito de _magnitude_ podemos finalmente entender um dos conceitos mais importantes em cálculos vetoriais: a normalização.

Agora, _normalização_ é algo já bem conhecido e aplicado em várias situações. O processo consiste em tornar um valor "normal", ou "padrão", de forma que simplifique o processo de compara-lo com outros valores "padrões". No nosso caso, um vetor "padrão" (ou, um vetor "normal") é um vetor que tenha uma magnitude de valor 1. Ou seja, quando normalizamos um vetor, nos iremos reduzir seu tamanho pra 1, porém, note que como só estamos alterando seu tamanho, sua __direção__ se manterá intacta! Com isso, teremos o que chamamos de __vetor unitário__.

[ilustração da normalização de um vetor]

E como podemos reduzir o tamanho de um vetor para exatamente `1`? A reposta é uma equação simples: basta dividirmos cada uma de suas propriedades (no nosso caso, os valores de x e y) pela magnitude do vetor:

[ilustração da normalização na prática]

Se não ficou claro, creio que ficará com a implementação:

```coffeescript
class Vector
  normalize: ->
    @div(@magnitude())
```

## Programando movimento com vetores

Até agora só vimos os conceitos básicos de vetores mas não fizemos nada prático que realmente justifique o uso deles. Por isso, é possível que vetores continuem parecendo pouco úteis. A verdade é que leva um tempo para se notar o quanto importante é saber utiliza-los, mas mesmo assim, isso vai mudar um pouco de agora em diante, já que iremos explorar alguns casos um pouco mais complexos.

Para começar, vamos ver algo muito utilizado em qualquer simulação física: __aceleração__.

Como já vimos, __velocidade__ é a quantidade de variação de posição. A __aceleração__ é a quantidade de variação de __velocidade__. Então podemos dizer que a _aceleração_ afeta a _velocidade_ e essa por sua vez afeta a _posição_. 

`velocity = velocity + acceleration`   
`position = position + velocity`

Que traduzindo para código, seria:

```coffeescript
velocity.add(acceleration)
position.add(velocity)
```

Como é possível notar, podemos alterar tanto a posição e a velocidade através da aceleração, com isso, nunca será necessário alterar os valores de velocidade e posição diretamente (apenas, é claro, no processo de inicialização). Esse processo, de não alterar diretamente os valores de velocidade e posição, por exemplo, é usado por todas as _engines_ físicas, ou seja, quando quisermos fazer um objeto se mover pela tela, temos que pensar em algorítimos para manipular sua _aceleração_. Para ficar claro, vamos ver alguns dos mais utilizados:

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

Como podemos notar, por enquanto as únicas modificações feitas foram zerar a velocidade e adicionar uma nova propriedade para a aceleração. Note também que a aceleração tem valores _muito_ pequenos, isso é necessário porque devemos lembrar que a cada iteração do nosso loop infinito, iremos somar esses valores na velocidade do círculo, e como temos 60 iterações desse loop por segundo, você já pode imaginar o que aconteceria que se o valor for muito grande...

Mas continuando, agora vamos alterar o método `update` para adicionar aceleração a nossa velocidade:

```coffeescript
update: ->
  @velocity.add @acceleration
  @position.add @velocity
```

Tudo irá funcionar perfeitamente com um porém: a velocidade nesse caso tende ao infinito, ou seja, se deixarmos o exemplo rodando por muito tempo, a velocidade acumulada será tão grande que não será mais possível ver o círculo na tela. Precisamos de algo que consiga _limitar_ nossa velocidade, e como a __velocidade__ é um vetor, podemos dizer então que precisamos de um método que possa _limitar_ o tamanho, ou melhor dizendo: limitar a magnitude de um vetor.

```coffeescript
class Vector
  limit: (max) ->
    if @mag() > max
      do @normalize
      @mult(max)
```

Note que aos poucos estamos fazendo uso de vários conceitos já vistos. A implementação é simples: basta checarmos se a magnitude é maior que a informada, se for, não fazemos nada, e se não for, normalizamos o vetor e escalamos ele para o tamanho máximo informado.

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

E o resultado disso tudo podemos ver no seguinte exemplo:

<script type="text/javascript" src="/coffee/bouncing_balls_with_constant_acceleration.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var example = new BouncngBallsWithConstantAcceleration("#constant_acceleration", 900, 290);
    example.start();
  });
</script>

<div id="constant_acceleration"></div>

### Aceleração aleatória

Esse segundo exemplo é de extrema importância pois mostra que aceleração não é apenas usada para fazer com que objetos, acelerem ou desacelerem, mas tambem é usada para _qualquer_ mudança de velocidade, seja essa uma mudança de magnitude (que é o que faz um objeto andar mais rápido ou mais devegar), como também uma __mudança de direção__, pois é muito comum utilizarmos vetores para alterar a direção de objetos, tanto que em artigos futuros iremos estudar os [algorítimos do Craig Reynolds](http://www.red3d.com/cwr/steer/), e todos eles fazem muito uso desse conceito.

Na próxima simulação, vamos pegar por base nosso último exemplo, e altera-lo para que a aceleração seja gerada a cada iteração, e não durante a inicialização do objeto.

Mas antes, precisamos criar uma simples função que retorna um número aleatório dentro de um range, já que o javascript não fornece algo do tipo nativamente:

```coffeescript
random = (min, max) -> Math.random() * (max - min) + min
```

E agora vamos redefinir o método `update` para que ele gere uma aceleração aleatória:

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

### Aceleração em direção a um ponto

Como último exemplo, vamos implementar a aceleração direcionada a um ponto. Esse ponto, pode ser qualquer coisa, seja ele um outro objeto, ou, como no nosso caso, o _mouse_. Sendo assim, teremos que implementar um algorítimo que acelere em _direção ao ponteiro do mouse_.

Para esse tipo de simulação nós sempre iremos precisar calcular duas coisas: a __magnitude__ e a __direção__.

Para computar a direção precisamos montar um vetor que vai da posição atual do objeto até o ponteiro do mouse. Podemos fazer isso com uma simples subtração (note que estamos utilizando nosso _método estático_): 

[ilustração de subtração]

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

E temos esse resultado (instanciando vários círculos):

<script type="text/javascript" src="/coffee/acceleration_towards_mouse.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var example = new AccelerationTowardsMouse("#acceleration_towards_mouse", 900, 300);
    example.start();
  });
</script>

<div id="acceleration_towards_mouse"></div>

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

Ainda existem (muitos) outros assuntos que podem ser abordados que utiliam vetores para simular eventos do mundo real. Por exemplo, você deve ter notado, que na nossa última simulação os círculos não "param" quando chegam no mouse, pelo contrário, eles "_passam_" por ele e depois precisam voltar (ficando nesse ciclo infinitamente). Isso acontece porque não estamos limitando a __força__ máxima que o vetor pode acelerar. Em futuros artigos, iremos estudar vários dos algorítimos do Crayg Reynolds, e um deles é o [_arrival_](http://www.red3d.com/cwr/steer/Arrival.html), que trata exatamente esse caso: um objeto que acelera até um ponto e desacelera a ponto de parar quando finalmente chega em seu destino.

Outra grande vantagem que ganhamos "quase de graça" quando utilizamos vetores, e que não foi explorada nesse artigo, é a conversã desses cálculos para um "mundo" `3D`. Para isso, bastava inicializar/manipular os vetores utilizando mais um eixo (convencionalmente chamado de eixo `z`). Tanto que converter os exemplos mostrados nessa página para suportar uma teceira dimensão é algo trivial, mas que ficará para um próximo artigo.

Por hora, espero que tenha ficado claro as vantagens do uso de vetores em simulações físicas, bem como as propriedades e operações que eles possuem.

### Agradecimentos

Muitas partes e exemplos desse artigo não foram só baseadas como quase transcritas de livros e tutoriais escritos pelo [Daniel Shiffman](http://www.shiffman.net) e pelo [Craig Reynolds](http://www.red3d.com/cwr). Portanto, todos os créditos devem ser dados a eles.

### Opensource

A classe `Vector` que criamos nesse artigo pode ser encontrada para download em seu [próprio repositório no github](http://github.com/reu/vector.js), desta forma quando precisar fazer calculos de vetores em javascript, basta inclui-la em seu projeto. Ela também dá suporte a vetores `3D`, coisa que não fizemos aqui.

Outra biblioteca usada nos exemplos é o [canvas-extensions](https://github.com/reu/canvas-extensions), que coloca alguns métodos úteis no `context` do `canvas` do HTML5 (como por exemplo, o método `fillCircle`).
