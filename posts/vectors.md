title: Vetores
author: Rodrigo Navarro

Em geral, existem duas maneiras que eu vejo que as pessoas entram nesse mundo:
1 - Fazendo do jeito mais amador, rápido e funcional possível. É o "sair fazendo", e isso inclui pesquisas no google, um monte de copy/paste e assim que seu código começa a crescer, vc vai notar o inferno que tudo isso virou. Além do mais, no próximo projeto, vc ainda irá sofrer, já que vc não "aprendeu" muita coisa.
2 - Como a popularidade do mundo opensource, hoje é possível encontrar bibliotecas de física impressionantes muito facilmente, e o melhor: de graça. Isso obviamente atrai os olhos de qualquer um. O problema é que assim como a Maneira 1, saber usar essas bibliotecas leva tempo, e se novamente vc não souber os conceitos por detrás desse "mundo simulado", o resultado será semelhante.

Indepentente das maneiras que vc escolheu começar, você acabará tendo o mesmo problema: você não conhece os conceitos básicos necessários para uma compreensão do "wtf is going on" do seu código. Se você não sabe o que é uma força, uma aceleração, não sabe como funcionam os vetores e nem como usá-los, por mais que você tente, você sempre irá ter muito mais dificuldade de entender e manter seu código.

# Vetores

Vamos deixar claro que quando eu digo _vetores_ eu não estou falando de _vetores_ como coleção de valores (os _arrays_), ou mesmo a classe _Vector_ do _Java_ (apesar de que o _Java_ implementa a classe _Vector_ de qual estou falando, só que ela chama _Vector2D/Vector3D_), na verdade, __vetor__ tem várias definições, e a que iremos ver nesse artigo é essa (tirado da wikipedia):

> Um conjunto de elementos geométricos, denominados segmentos de reta orientados, que possuem todos a mesma intensidade (denominada norma ou módulo), mesma direção e mesmo sentido.

Talvez essa definição tenha atrapalhado mais do que ajudado, mas acredite, é bem mais simples do que parece.

Mas antes de entender exatamente _o que_ eles são, é interessante entender o _porquê_ vetores são tão importantes para simulações físicas. Para isso, nada melhor que um exemplo prático, que em um primeiro momento será implementado da maneira mais simplista possível (sem o uso de vetores), e posteriormente utilizando vetores.

## Sobre os exemplos

Todos os códigos serão demonstrados usando [Coffeescript](http://coffeescript.org/). Se você ainda não conhece essa linguagem, vale uma rápida consulta na documentação para se familiarizar com a sintaxe. Basicamente é uma forma ~~menos sofrida~~ mais elegante de se escrever Javascript.

Além disso, muitos dos códigos na página serão uma versão um pouco simplificada da implementação em si. Por exemplo, não será detalhado a parte de renderização dos objetos na tela ou a criação dos contextos do canvas do HTML na maior parte das vezes. O foco será mais nos conceitos e menos nas tecnologias em si. De qualquer forma, você pode consultar o código completo de todos os exemplos [nesse repositório no github](http://github.com/reu/blog/public/vectors/aqui).

## O _hello world_ das simulações físicas

<script type="text/javascript" src="/coffee/request_animation_frame.js"></script>
<script type="text/javascript" src="/coffee/bouncing_balls_without_vectors.js"></script>
<script type="text/javascript">
  jQuery(function($){
    var firstExample = new FirstExample(190, 190);
    firstExample.start();
  });
</script>

<div id="first_example"></div>

Como o primeiro exemplo, vamos criar um dos cenário mais comuns em tutoriais de físicas: um círculo que rebate na tela. A estrutura é bem simples: teremos um loop infinito que a irá alterar a posição do círculo a cada iteração. Como esse loop roda em irá rodar 60 vezes por segundo, o que iremos ter é uma _ilusão de movimento_, já que a cada iteração (também chamado de _frame_) o círculo estará em uma nova posição.

```coffeescript
class Ball
  constructor: (@x, @y) ->
    # Setting some random velocities here
    @xSpeed = 3
    @ySpeed = 1.5

    # The size of the ball
    @radius = 10

  # Increment the ball position based on its current speed
  update: ->
    @x += xSpeed
    @y += ySpeed

  # Inverts the ball velocity when it hits any of the bounds of the canvas
  checkBounds: (area) ->
    # Inverting the x velocity when the ball touches the left or right side of the screen
    @xSpeed *= -1 if @x > area.width  or @x < 0

    # Inverting the y velocity when the ball touches the up or down side of the screen
    @ySpeed *= -1 if @y > area.height or @y < 0

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

Começa a ficar cada vez mais evidente que para cada conceito físico que quizermos adicionar na nossa simulação (gravidade, vento, etc), nós precisamos de dois valores, um `x` e um `y`. Isso acontece porque estamos trabalhando num contexto 2D, se a nossa simulação fosse em 3D, notaríamos que iríamos precisar de ainda mais um valor, que seria referente ao eixo `z`. Por hora, para simplificar as coisas, duas dimensões é o suficiente.

Com isso em mente, e se pudéssmos agrupar esses valores em algum tipo de estrutura, de modo simplificar (e generalizar) o processo? Afinal, não ficaria mais organizado se ao invés de escrever dessa maneira:

```coffeescript
@x = 4
@y = 8
@xSpeed = 1.5
@ySpeed = 3
```

Escrevessemos dessa?

```coffeescript
@position = new Vector(4, 8)
@speed    = new Vector(1, 3)
```

Sim, acabamos de escrever nossos dois primeiros vetores, que até então não parecem trazer muitas vantagens, mas não se preucupe, isso é só o começo.

## Meet the Vector

Vetores são, resumidamente, a **diferença entre dois pontos**. Relembrando o que foi dito sobre o exemplo anterior, nós estamos instruindo o círculo a alterar sua posição a cada iteração por um número de pixels horizontais e um número de pixels verticais (que, novamente, foi o que chamamos de **velocidade**), que no caso se traduz para:

`position = position + speed`

Com isso, podemos afirmar que nossa **velocidade** é um vetor, já que ela descreve a diferença entre dois pontos: o ponto atual do objeto, e o ponto que o objeto vai estar após a iteração.

Mas agora você pode se perguntar, e a **posição**? É também considerada um vetor? Apesar de ela também ter as propriedades `x` e `y`, ela não descreve a diferença entre dois pontos, ela apenas especifica uma coordenada. Apesar de algumas linguagens (como o _Java_) terem classes distintas para especificar uma _coordenada_ e um _vetor_, a maior parte das linguagens e _engines físicas_ simplificam esse caso e tratam a coordenada _também_ como um vetor, afinal, uma outra forma descrever a posição é como a **diferença entre a origem (0, 0) para a posição atual**. Desta forma, eliminamos a burocracia de ter duas classes que representam a mesma coisa só que com nomes diferentes.

Mas voltando ao exemplo, tinhamos:

```coffeescript
position = x, y
velocity = xSpeed, ySpeed
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
    @speed    = new Vector(3, 1.5)
```

Com isso, podemos finalmente implementar nosso algorítimo de movimento usando vetores! Apenas relembrando, na implementação original nós tinhamos:

```coffeescript
@x += xSpeed
@y += ySpeed
```

E o que gostaríamos de fazer agora seria:

```coffeescript
@position = @position + @speed
```

Infelizmente como estamos trabalhado com javascript nos exemplos, você já deve saber que essa sintaxe não é permitida pela linguagem, já que não podemos implementar uma função de soma de dois objetos da classe `Vector` utilizando o simbolo `+` (na verdade, a única linguagem que conheço que permitiria tal sintaxe é o _Ruby_). Isso quer dizer que o _javascript_ não sabe como _somar_ dois vetores como ele sabe como _somar_ dois inteiros ou até mesmo _"somar"_ duas strings utilizando o operador `+`, logo, a única opção é fazer isso por nossa conta utilizando uma sintaxe um pouco diferente.

### Somando vetores

Bom, já temos uma primeira versão da nossa classe `Vector` que basicamente é uma estrutura que possui os componentes `x` e `y`. Agora teremos que implementar um método nessa classe que irá somar um vetor a uma instância dela. Mas antes, é importante entender o que significa somar dois vetores. Para isso, vamos primeiro nos familiarizar com algumas notações matemáticas usadas para representar vetores.

Vetores normalmente são representados com as letras em negrito e/ou com uma seta em cima do seu nome. Para facilitar a escrita, vamos utilizar apenas as letras em negrito para diferenciar um vetor de um escalar (escalar se refere a um valor inteiro ou decimal, como a posição x e y):

Com isso em mente, vamos finalmente entender como funciona a soma de vetores. Já sabemos que cada vetor tem dois componentes, um `x` e um `y`. Para somar um vetor com outro, basta somar os componentes `x` e `y` de ambos.

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

Com isso, vamos agora finalmente terminar a refatoração do nosso exemplo:

```coffeescript
class Ball
  constructor: (x, y) ->
    @position = new Vector x, y
    @speed    = new Vector 3, 1.5
    @radius = 10

  update: ->
    # Incrementing the ball position by adding the speed vector to the position vector
    @position.add(@speed)

  checkBounds: (area) ->
    # Of course we can read/write the x and y components of a vector
    @speed.x *= -1 if @position.x > area.width  or @position.x < 0
    @speed.y *= -1 if @position.y > area.height or @position.y < 0

  draw: (context) ->
    # As the canvas API doesn't support passing vectors as arguments, we must inform the x and y scalars
    context.fillCircle @position.x, @position.y, @radius
```



Ideia da carinha com olhos que seguem o mouse pra explicar normalização e aumentar o tamanho dos olhos pr explicar magnetude.
