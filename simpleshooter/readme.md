## Space Shooter Simples (LÖVE + Lua)

Este é um projeto de um jogo 2D de tiro espacial, criado para praticar os conceitos fundamentais do desenvolvimento de jogos com a engine LÖVE e a linguagem Lua.

**Objetivo:** Controlar uma nave na base da tela, atirar em inimigos que descem do topo e marcar o máximo de pontos possível. O jogo termina se um inimigo alcançar a parte inferior.

### Controles

* **Setas (Esquerda/Direita):** Mover a nave.
* **Barra de Espaço:** Atirar.
* **'R':** Reiniciar o jogo após o "Game Over".

### Dissecando o Código

#### Estrutura Principal

O jogo é organizado em torno das funções de callback do LÖVE:
* **`love.load()`**: Executada uma única vez para inicializar variáveis, como as tabelas do jogador (`player`), dos tiros (`bullets`) e dos inimigos (`enemies`), além de definir o estado inicial do jogo (`gameState = "playing"`).
* **`love.update(dt)`**: Contém toda a lógica que roda a cada frame: movimento, criação de inimigos, detecção de colisões e atualização do estado do jogo. O uso de `dt` (delta time) garante que a velocidade do jogo seja independente do hardware.
* **`love.draw()`**: Responsável por desenhar todos os elementos na tela a cada frame, com base nas informações atualizadas pelo `love.update()`.
* **`love.keypressed(key)`**: Função de evento usada para ações de um único toque, como atirar. É diferente de `love.keyboard.isDown()`, que é checada continuamente no `update` para movimentos.

#### Gerenciamento de Objetos

O código utiliza tabelas Lua para gerenciar múltiplos objetos dinâmicos (tiros e inimigos).
* **Criação:** A função `table.insert()` é usada para adicionar novos tiros à tabela `bullets` e novos inimigos à tabela `enemies`.
* **Remoção:** `table.remove()` é utilizada para deletar objetos que saem da tela ou são destruídos. Para evitar bugs, a iteração sobre as tabelas para remoção é feita com um loop reverso (`for i = #tabela, 1, -1 do`).

#### Lógica de Colisão e Bugs

A colisão é detectada com uma função que checa a sobreposição de retângulos (AABB). O principal desafio foi um erro de `valor nil` que ocorria ao remover um objeto durante a verificação de colisão.
* **Solução:** Foi implementada uma verificação `if currentBullet and currentEnemy then` antes de testar a colisão. Isso garante que o código não tente acessar as propriedades de um objeto que já foi removido na mesma iteração, tornando a lógica robusta.

#### Estados de Jogo (`gameState`)

Uma variável `gameState` ("playing", "gameover") controla o fluxo do jogo. Isso permite que a lógica de `update` e `draw` se comporte de maneira diferente, executando a jogabilidade normal ou exibindo a tela de "Game Over" e aguardando o comando para reiniciar.