-- main.lua para o jogo "Space Shooter Simples"

-- === VARIÁVEIS GLOBAIS ===
local player = {}
local bullets = {}    -- Tabela para armazenar todos os tiros
local enemies = {}    -- Tabela para armazenar todos os inimigos
local gameState = "playing" -- Estados do jogo: "playing", "gameover"

local score = 0
local font

local windowWidth = 800
local windowHeight = 600

-- === FUNÇÃO love.load() ===
function love.load()
    love.window.setTitle("Space Shooter Simples")
    love.window.setMode(windowWidth, windowHeight)

    -- Configuração do jogador (nave)
    player.x = windowWidth / 2 - 50 -- Centrado na parte de baixo
    player.y = windowHeight - 70
    player.width = 100
    player.height = 20
    player.speed = 300

    -- Configuração dos tiros (propriedades padrão)
    bullet = {}
    bullet.width = 5
    bullet.height = 15
    bullet.speed = 400

    -- Configuração dos inimigos (propriedades padrão)
    enemy = {}
    enemy.width = 40
    enemy.height = 40
    enemy.speed = 100
    enemy.spawnTimer = 2 -- Tempo em segundos para criar um novo inimigo
    enemy.spawnCooldown = 0

    -- Font para a pontuação e game over
    font = love.graphics.newFont(24)
    gameOverFont = love.graphics.newFont(48)

    -- Gera o primeiro inimigo
    spawnEnemy()
end

-- === FUNÇÃO love.update(dt) ===
function love.update(dt)
    if gameState == "playing" then
        -- === Lógica do Jogador ===
        if love.keyboard.isDown("left") then
            player.x = player.x - (player.speed * dt)
        end
        if love.keyboard.isDown("right") then
            player.x = player.x + (player.speed * dt)
        end

        -- Limitar o jogador dentro da tela
        if player.x < 0 then
            player.x = 0
        end
        if player.x + player.width > windowWidth then
            player.x = windowWidth - player.width
        end

        -- === Lógica dos Tiros ===
        for i = #bullets, 1, -1 do -- Iterar de trás pra frente para remover elementos
            local currentBullet = bullets[i]
            currentBullet.y = currentBullet.y - (bullet.speed * dt)

            -- Remover tiro se sair da tela
            if currentBullet.y < 0 then
                table.remove(bullets, i)
            end
        end

        -- === Lógica dos Inimigos ===
        enemy.spawnCooldown = enemy.spawnCooldown - dt
        if enemy.spawnCooldown <= 0 then
            spawnEnemy()
            enemy.spawnCooldown = enemy.spawnTimer
        end

        for i = #enemies, 1, -1 do
            local currentEnemy = enemies[i]
            currentEnemy.y = currentEnemy.y + (enemy.speed * dt)

            -- Verificar se inimigo passou do jogador (Game Over)
            if currentEnemy.y > windowHeight then
                gameState = "gameover"
                break -- Sai do loop de inimigos, o jogo acabou
            end
        end

        -- === Lógica de Colisões (Tiro vs Inimigo) ===
        for i = #bullets, 1, -1 do
            local currentBullet = bullets[i]
            for j = #enemies, 1, -1 do
                local currentEnemy = enemies[j]

                if checkCollision(currentBullet, currentEnemy) then
                    score = score + 1
                    table.remove(bullets, i) -- Remove o tiro
                    table.remove(enemies, j) -- Remove o inimigo
                    break -- Quebra o loop interno (inimigo), pois o tiro já colidiu
                end
            end
        end

    elseif gameState == "gameover" then
        -- Se estiver em Game Over, permite reiniciar o jogo
        if love.keyboard.isDown("r") then
            resetGame()
        end
    end
end

-- === FUNÇÃO love.draw() ===
function love.draw()
    -- Desenha o jogador (nave)
    love.graphics.setColor(1, 1, 1) -- Branco
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

    -- Desenha todos os tiros
    love.graphics.setColor(0, 1, 0) -- Verde
    for _, currentBullet in ipairs(bullets) do
        love.graphics.rectangle("fill", currentBullet.x, currentBullet.y, bullet.width, bullet.height)
    end

    -- Desenha todos os inimigos
    love.graphics.setColor(1, 0, 0) -- Vermelho
    for _, currentEnemy in ipairs(enemies) do
        love.graphics.rectangle("fill", currentEnemy.x, currentEnemy.y, enemy.width, enemy.height)
    end

    -- Desenha a pontuação
    love.graphics.setColor(1, 1, 0) -- Amarelo
    love.graphics.setFont(font)
    love.graphics.print("Score: " .. score, 10, 10)

    -- Desenha a tela de Game Over se o jogo acabou
    if gameState == "gameover" then
        love.graphics.setFont(gameOverFont)
        love.graphics.setColor(1, 1, 1) -- Branco
        local gameOverText = "GAME OVER!\nPressione 'R' para Reiniciar"
        local textWidth = gameOverFont:getWidth(gameOverText)
        local textHeight = gameOverFont:getHeight(gameOverText)
        love.graphics.printf(gameOverText, 0, windowHeight / 2 - textHeight / 2, windowWidth, "center")
    end
end

-- === FUNÇÃO love.keyboard.keypressed() ===
-- Esta função especial do LÖVE é chamada quando uma tecla é pressionada UMA VEZ
function love.keyboard.keypressed(key)
    if gameState == "playing" then
        if key == "space" then
            shootBullet()
        end
    end
end

-- === FUNÇÕES AUXILIARES ===

-- Função para criar um novo tiro
function shootBullet()
    local newBullet = {}
    newBullet.x = player.x + (player.width / 2) - (bullet.width / 2) -- Centrado na nave
    newBullet.y = player.y - bullet.height -- Acima da nave
    table.insert(bullets, newBullet) -- Adiciona o novo tiro à lista de tiros
end

-- Função para criar um novo inimigo
function spawnEnemy()
    local newEnemy = {}
    newEnemy.x = math.random(0, windowWidth - enemy.width) -- Posição X aleatória
    newEnemy.y = -enemy.height -- Começa fora da tela, no topo
    table.insert(enemies, newEnemy) -- Adiciona o novo inimigo à lista de inimigos
end

-- Função para verificar colisão (AABB)
function checkCollision(obj1, obj2)
    return obj1.x < obj2.x + obj2.width and
           obj1.x + obj1.width > obj2.x and
           obj1.y < obj2.y + obj2.height and
           obj1.y + obj1.height > obj2.y
end

-- Função para resetar o jogo
function resetGame()
    player.x = windowWidth / 2 - 50
    player.y = windowHeight - 70
    bullets = {}
    enemies = {}
    score = 0
    gameState = "playing"
    enemy.spawnCooldown = enemy.spawnTimer -- Reseta o timer de spawn
    spawnEnemy() -- Gera um inimigo inicial
end