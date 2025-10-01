-- main.lua para o jogo "Apanhador de Frutas"

function love.load()
    -- Configurações da janela
    love.window.setTitle("Apanhador de Frutas")
    love.window.setMode(800, 600) -- Largura e altura da janela

    -- Variáveis do Jogador (o nosso "cesto")
    player = {} -- Usamos uma tabela para organizar as propriedades
    player.x = 350      -- Posição inicial no eixo X (horizontal)
    player.y = 550      -- Posição inicial no eixo Y (vertical)
    player.width = 100  -- Largura do jogador
    player.height = 20  -- Altura do jogador
    player.speed = 400  -- Velocidade de movimento do jogador

    -- Variáveis da "Fruta"
    fruit = {}
    fruit.width = 30
    fruit.height = 30
    fruit.speed = 250
    -- Chama uma função para resetar a posição da fruta
    resetFruit()

    -- Variáveis do Jogo
    score = 0
    font = love.graphics.newFont(24) -- Cria uma fonte para exibir o texto
end

function love.update(dt)
    -- Mover o jogador com as setas do teclado
    if love.keyboard.isDown("left") then
        player.x = player.x - (player.speed * dt) -- Move para a esquerda
    end
    if love.keyboard.isDown("right") then
        player.x = player.x + (player.speed * dt) -- Move para a direita
    end

    -- Impedir que o jogador saia da tela
    if player.x < 0 then
        player.x = 0
    end
    if player.x + player.width > love.graphics.getWidth() then
        player.x = love.graphics.getWidth() - player.width
    end

    -- Mover a fruta (fazendo ela cair)
    fruit.y = fruit.y + (fruit.speed * dt)

    -- Verificar se a fruta saiu da tela (o jogador não pegou)
    if fruit.y > love.graphics.getHeight() then
        resetFruit() -- Reposiciona a fruta no topo
        score = 0 -- Opcional: zera a pontuação se errar
    end

    -- Verificar colisão entre o jogador e a fruta
    if checkCollision(player, fruit) then
        score = score + 1 -- Aumenta a pontuação
        resetFruit() -- Reposiciona a fruta
    end
end

function love.draw()
    -- Desenha o jogador (um retângulo)
    love.graphics.setColor(1, 1, 1) -- Define a cor para branco (R, G, B)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

    -- Desenha a fruta (outro retângulo)
    love.graphics.setColor(1, 0, 0) -- Define a cor para vermelho
    love.graphics.rectangle("fill", fruit.x, fruit.y, fruit.width, fruit.height)

    -- Desenha a pontuação na tela
    love.graphics.setColor(1, 1, 0) -- Define a cor para amarelo
    love.graphics.setFont(font)
    love.graphics.print("Pontos: " .. score, 10, 10)
end

-- Função para verificar colisão (lógica AABB - Axis-Aligned Bounding Box)
function checkCollision(obj1, obj2)
    return obj1.x < obj2.x + obj2.width and
           obj1.x + obj1.width > obj2.x and
           obj1.y < obj2.y + obj2.height and
           obj1.y + obj1.height > obj2.y
end

-- Função para reposicionar a fruta no topo em um lugar aleatório
function resetFruit()
    fruit.x = math.random(0, love.graphics.getWidth() - fruit.width)
    fruit.y = -fruit.height -- Começa um pouco acima da tela para um efeito suave
end