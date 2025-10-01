# Repositório de Estudos da Linguagem Lua

Este repositório serve como um registro do meu estudo progressivo da linguagem de programação Lua. O objetivo é documentar a implementação de conceitos fundamentais da linguagem e aplicá-los no desenvolvimento de software, com um foco inicial no framework LÖVE para a criação de jogos 2D.

---

## Estrutura do Repositório

A organização dos arquivos segue uma estrutura modular para separar a teoria da prática:

* **/Conceitos_Basicos:** Contém scripts de exemplo autocontidos, cada um demonstrando uma característica específica da linguagem Lua (e.g., metatables, coroutines, manipulação de tabelas).
* **/Projetos:** Diretórios contendo implementações práticas e funcionais. Cada subdiretório representa um projeto independente, com seu próprio código-fonte e recursos.
* **/Recursos:** Coleção de links para documentação oficial, artigos técnicos e outras referências relevantes.

---

## Projetos Implementados

Abaixo estão os projetos desenvolvidos, que servem como aplicação prática dos conceitos estudados.

### 1. Apanhador de Frutas
* **Descrição Técnica:** Implementação de um jogo simples para validar o entendimento do ciclo de vida (game loop) do LÖVE. O projeto aborda a renderização de primitivas, o tratamento de input de teclado para movimentação de entidades e a detecção de colisão através do algoritmo AABB (Axis-Aligned Bounding Box).
* **Status:** Concluído.

### 2. Space Shooter Simples
* **Descrição Técnica:** Evolução do projeto anterior, focado no gerenciamento dinâmico de múltiplas entidades. Foram implementadas estruturas de dados (tabelas) para controlar a criação e destruição de projéteis e inimigos em tempo de execução. O projeto também introduz uma máquina de estados finitos (FSM) simples, através da variável `gameState`, para gerenciar os diferentes estados da aplicação (e.g., "em jogo", "fim de jogo").
* **Status:** Concluído e funcional.

---

## Tópicos e Conceitos Implementados

Esta seção cataloga os principais conceitos da linguagem e do framework que foram estudados e aplicados nos projetos.

* **Sintaxe e Semântica:** Escopo de variáveis (local e global), operadores, sintaxe de controle de fluxo (`if`, `for`, `while`).
* **Estrutura de Dados `table`:** Utilização como arrays, hash maps (dicionários) e para a implementação de objetos simples.
* **Funções:** Declaração, múltiplos valores de retorno e passagem de funções como argumentos.
* **Ciclo de Vida de Jogo (Game Loop):** Implementação das funções de callback do LÖVE: `love.load` (inicialização), `love.update` (lógica de estado) e `love.draw` (renderização).
* **Tratamento de Input:** Distinção e aplicação de eventos (`love.keypressed`) e checagem de estado (`love.keyboard.isDown`).
* **Gerenciamento de Estado:** Implementação de uma máquina de estados finitos para controlar o fluxo da aplicação.
* **Manipulação de Coleções Dinâmicas:** Uso de `table.insert()` e `table.remove()`, com atenção à iteração reversa para evitar erros de índice durante a remoção de elementos.
* **Resolução de Erros:** Depuração de erros de referência nula (`nil value`) resultantes do acesso a objetos removidos de coleções dinâmicas.

---

## Objetivos Futuros de Estudo

Os próximos tópicos a serem explorados para aprofundar o conhecimento são:

* **Gerenciamento de Assets:** Carregamento e renderização de sprites e execução de arquivos de áudio.
* **Animação:** Implementação de animações baseadas em spritesheets.
* **Modularização de Código:** Organização de projetos em múltiplos arquivos `.lua` utilizando `require`.
* **Programação Orientada a Objetos:** Exploração de metatables para criar sistemas de classes e herança.
* **Implementação de UI (Interface de Usuário):** Desenvolvimento de menus, botões e outros elementos de interface.

---

## Recursos e Documentação

* [**Documentação Oficial do Lua**](https://www.lua.org/docs.html)
* [**LÖVE Framework Wiki**](https://love2d.org/wiki/Main_Page)
* [**Programming in Lua (Primeira Edição)**](https://www.lua.org/pil/contents.html)
