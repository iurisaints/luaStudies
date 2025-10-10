## Jogo de Xadrez em Lua com LÖVE

**Versão:** 1.4  
**Data:** 10 de Outubro de 2025  
**Autor:** Iuri Nascimento Santos

### 1. Visão Geral

#### 1.1. Objetivo
O objetivo deste projeto é a criação de um jogo de xadrez 2D completo, servindo como um estudo de caso prático para a aplicação de lógica de jogos baseados em turnos, manipulação de estruturas de dados e gerenciamento de estado em Lua e LÖVE.

#### 1.2. Escopo de Funcionalidades
* Interface gráfica 2D com tabuleiro e peças.
* Implementação completa das regras de movimento para todas as 6 peças de xadrez.
* Sistema de turnos para jogadores (Brancas e Pretas).
* Lógica para captura de peças.
* Implementação das regras especiais:
    * Roque (lado do rei e da rainha).
    * Promoção do Peão.
    * Captura *En Passant*.
* Detecção de condições de fim de jogo:
    * Xeque-Mate.
    * Empate por Afogamento (Stalemate).
    * Empate por Tripla Repetição.
* Interface de usuário para seleção e movimentação de peças via mouse.

#### 1.3. Tecnologias Utilizadas
* **Linguagem:** Lua 5.1 (padrão do LÖVE).
* **Framework:** LÖVE (Love2D) 11.x, utilizado para gerenciamento da janela, renderização gráfica e tratamento de input.

### 2. Arquitetura do Software

O projeto, contido em um único arquivo `main.lua`, é estruturado em torno do ciclo de vida do LÖVE e uma máquina de estados finitos (FSM) simples para gerenciar o fluxo do jogo.

#### 2.1. Representação de Dados

A fundação do jogo reside em como o estado é armazenado.

* **Tabuleiro (`board`):** O tabuleiro 8x8 é representado por uma matriz 2D (uma tabela de tabelas), onde `board[y][x]` contém o objeto da peça ou `nil` se a casa estiver vazia. A indexação é baseada em 1 (padrão de Lua), com `[1][1]` sendo o canto superior esquerdo (casa a8).

* **Peças (`piece`):** Cada peça é uma tabela (objeto) com as seguintes propriedades:
    * `type`: (string) O tipo da peça ("pawn", "rook", "knight", etc.).
    * `color`: (string) A cor da peça ("white" ou "black").
    * `hasMoved`: (boolean) Flag para rastrear se a peça já se moveu, essencial para as regras de roque e o primeiro movimento do peão.

* **Estado do Jogo (`gameState`):** Uma única tabela que centraliza todo o estado dinâmico do jogo:
    * `state`: (string) Controla o estado da aplicação ("playing", "promotion", "gameover").
    * `turn`: (string) Indica qual cor tem a vez ("white" ou "black").
    * `selectedPiece`: (tabela) Armazena as coordenadas `{x, y}` da peça atualmente selecionada.
    * `validMoves`: (array de tabelas) Lista os movimentos `{x, y, ...}` válidos para a peça selecionada.
    * `enPassantTarget`: (tabela) Armazena as coordenadas `{x, y}` do alvo de uma possível captura *en passant*.
    * `history`: (tabela) Um hash map que armazena strings FEN como chaves e sua contagem de ocorrências como valor, para a regra de tripla repetição.
    * `winner`: (string) Armazena o resultado do jogo quando o estado é "gameover".

#### 2.2. Ciclo de Vida e Fluxo de Controle

O fluxo é controlado pelas funções de callback do LÖVE.
* **`love.load()`**: Inicializa a janela, carrega os assets (imagens das peças) e chama `startNewGame()` para configurar o estado inicial do tabuleiro e do `gameState`.
* **`love.draw()`**: Renderiza o estado atual do jogo a cada frame. A lógica de desenho é condicional ao `gameState.state`, exibindo o tabuleiro, as peças, os destaques de movimento, a UI de promoção ou a tela de fim de jogo.
* **`love.mousepressed()`**: É o principal gatilho para a lógica do jogo. A sua ação é roteada com base no `gameState.state` para as funções `handlePlayStateClick`, `handlePromotionClick` ou para reiniciar o jogo.

### 3. Implementação da Lógica de Jogo

A complexidade do xadrez está na validação das regras. A arquitetura de validação foi projetada para ser segura e extensível.

#### 3.1. Validação de Movimentos
O processo é dividido em três camadas:

1.  **`getPseudoLegalMoves(piece, x, y)`**: Esta função atua como um dispatcher. Ela chama a função de movimento específica da peça (ex: `getValidRookMoves`) para gerar uma lista de movimentos "pseudo-legais", baseados apenas na geometria de movimento da peça, sem considerar o xeque.

2.  **`isSquareAttacked(x, y, attackerColor)`**: Uma função otimizada e fundamental que determina se uma casa específica está sob ataque por uma peça da cor do atacante. Ela faz isso "olhando" para fora a partir da casa-alvo em todas as direções relevantes para cada tipo de peça, em vez de gerar todos os movimentos de todas as peças inimigas.

3.  **`getTrulyValidMoves(piece, x, y)`**: A camada final de validação. Ela primeiro obtém os movimentos pseudo-legais. Em seguida, para cada movimento, ela **simula** a jogada em uma cópia temporária do estado do tabuleiro. Após a simulação, ela chama `isKingInCheck()` (que por sua vez usa `isSquareAttacked()`) para verificar se o próprio rei ficou em perigo. Apenas os movimentos que não resultam em auto-xeque são retornados como "verdadeiramente válidos".

#### 3.2. Regras Especiais e de Fim de Jogo

* **Roque e *En Passant***: São implementados adicionando flags especiais (`isCastling`, `isEnPassant`) aos objetos de movimento retornados pelas funções de movimento. A função `executeMove()` verifica a presença dessas flags para realizar as ações secundárias necessárias (mover a torre ou remover o peão capturado).

* **Tripla Repetição**: É gerenciada pela função `generateFEN()`, que cria uma representação textual única e completa da posição atual (peças, turno, direitos de roque, alvo *en passant*). Após cada jogada, este "hash" é armazenado e sua contagem é incrementada na tabela `gameState.history`. A função `checkEndGame()` verifica se a contagem para a posição atual atingiu 3.

* **Xeque-Mate e Afogamento**: A detecção ocorre em `checkEndGame()`. A função itera sobre todas as peças do jogador do turno atual e tenta gerar movimentos válidos com `getTrulyValidMoves()`. Se nenhuma peça consegue gerar um único movimento válido, o jogo terminou. O resultado (xeque-mate ou afogamento) é determinado verificando se o rei está em xeque no momento.
