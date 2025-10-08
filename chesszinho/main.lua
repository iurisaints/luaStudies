-- ===================================================================
-- Jogo de Xadrez em Lua e LÖVE
-- v1.3: Correções Finais (Imagem do Cavalo, Tripla Repetição)
-- Prof. Iuri Nascimento Santos
-- ===================================================================

function love.load()
    love.window.setTitle("Xadrez em Lua")
    love.window.setMode(800, 800)
    love.graphics.setDefaultFilter("nearest", "nearest")
    squareSize, boardSize, board, gameState = 100, 8, {}, {}
    loadPieceImages(); startNewGame()
end

function love.draw()
    drawBoard(); drawHighlights(); drawPieces()
    if gameState.state == "promotion" then
        drawPromotionUI()
    elseif gameState.state == "gameover" then
        drawGameOverUI()
    end
end

function love.mousepressed(px, py, btn)
    if btn ~= 1 then return end
    if gameState.state == "playing" then
        handlePlayStateClick(px, py)
    elseif gameState.state == "promotion" then
        handlePromotionClick(px, py)
    elseif gameState.state == "gameover" then
        startNewGame()
    end
end

-- SEÇÃO 1: LÓGICA DE INTERAÇÃO E ESTADO
function handlePlayStateClick(px, py)
    local gx, gy = math.floor(px / squareSize) + 1, math.floor(py / squareSize) + 1
    if not (gx >= 1 and gx <= 8 and gy >= 1 and gy <= 8) then return end
    if gameState.selectedPiece then
        local move = isMoveValid(gx, gy, gameState.validMoves)
        if move then
            executeMove(move)
        else
            local p = board[gy][gx]; if p and p.color == gameState.turn then selectPiece(p, gx, gy) else deselectPiece() end
        end
    else
        local p = board[gy][gx]; if p and p.color == gameState.turn then selectPiece(p, gx, gy) end
    end
end

function handlePromotionClick(px, py)
    local choices = { "queen", "rook", "bishop", "knight" }; local sX, sY = (800 - squareSize * #choices) / 2,
        (800 - squareSize) / 2
    if py >= sY and py <= sY + squareSize then
        for i, ch in ipairs(choices) do
            local cX = sX + (i - 1) * squareSize
            if px >= cX and px <= cX + squareSize then
                local pSq = gameState.promotionSquare; board[pSq.y][pSq.x] = createPiece(ch, gameState.turn)
                gameState.state = "playing"; switchTurn(); updateHistoryAndCheckEndGame(); return
            end
        end
    end
end

function selectPiece(p, x, y)
    gameState.selectedPiece = { x = x, y = y }; gameState.validMoves = getTrulyValidMoves(p, x, y)
end

function deselectPiece() gameState.selectedPiece, gameState.validMoves = nil, {} end

function executeMove(move)
    local ox, oy = gameState.selectedPiece.x, gameState.selectedPiece.y
    local pieceToMove = board[oy][ox]
    gameState.enPassantTarget = nil
    if pieceToMove.type == "pawn" and math.abs(move.y - oy) == 2 then
        gameState.enPassantTarget = {
            x = ox,
            y = (oy + move.y) /
                2
        }
    end
    board[move.y][move.x], board[oy][ox] = pieceToMove, nil; pieceToMove.hasMoved = true
    if move.isEnPassant then
        local capY = (pieceToMove.color == "white") and move.y + 1 or move.y - 1; board[capY][move.x] = nil
    end
    if move.isCastling then
        if move.x == 7 then
            local r = board[move.y][8]; board[move.y][6], board[move.y][8] = r, nil; r.hasMoved = true
        elseif move.x == 3 then
            local r = board[move.y][1]; board[move.y][4], board[move.y][1] = r, nil; r.hasMoved = true
        end
    end
    deselectPiece()
    if pieceToMove.type == "pawn" and (move.y == 1 or move.y == 8) then
        gameState.state, gameState.promotionSquare = "promotion", { x = move.x, y = move.y }
    else
        switchTurn(); updateHistoryAndCheckEndGame()
    end
end

function switchTurn() gameState.turn = (gameState.turn == "white") and "black" or "white" end

function updateHistoryAndCheckEndGame()
    local fen = generateFEN()
    gameState.history[fen] = (gameState.history[fen] or 0) + 1
    print("FEN Gerado: " .. fen .. " | Contagem: " .. gameState.history[fen]) -- Linha de depuração
    checkEndGame()
end

function checkEndGame()
    local fen = generateFEN()
    if gameState.history[fen] and gameState.history[fen] >= 3 then
        gameState.state = "gameover"; gameState.winner = "Draw by Repetition"; return
    end
    for y = 1, 8 do
        for x = 1, 8 do
            local p = board[y][x]; if p and p.color == gameState.turn and #getTrulyValidMoves(p, x, y) > 0 then return end
        end
    end
    gameState.state = "gameover"; if isKingInCheck(gameState.turn) then
        gameState.winner = (gameState.turn == "white") and
            "Black" or "White"
    else
        gameState.winner = "Draw"
    end
end

-- SEÇÃO 2: LÓGICA DE VALIDAÇÃO DE MOVIMENTOS E REGRAS
function getTrulyValidMoves(p, x, y)
    local tV, pL = {}, getPseudoLegalMoves(p, x, y); for _, m in ipairs(pL) do
        local oP, cEP = board[m.y][m.x], nil; if m.isEnPassant then
            local cY = (p.color == "white") and m.y + 1 or m.y - 1; cEP = board[cY][m.x]; board[cY][m.x] = nil
        end; board[m.y][m.x], board[y][x] = p, nil; if not isKingInCheck(p.color) then table.insert(tV, m) end; board[y][x], board[m.y][m.x] =
            p, oP; if m.isEnPassant then
            local cY = (p.color == "white") and m.y + 1 or m.y - 1; board[cY][m.x] = cEP
        end
    end; return tV
end

function getPseudoLegalMoves(p, x, y)
    if p.type == "pawn" then
        return getValidPawnMoves(p, x, y)
    elseif p.type == "rook" then
        return getValidRookMoves(p, x,
            y)
    elseif p.type == "knight" then
        return getValidKnightMoves(p, x, y)
    elseif p.type == "bishop" then
        return
            getValidBishopMoves(p, x, y)
    elseif p.type == "queen" then
        return getValidQueenMoves(p, x, y)
    elseif p.type == "king" then
        return
            getValidKingMoves(p, x, y)
    end; return {}
end

function isSquareAttacked(tX, tY, attColor)
    local pD = (attColor == "white") and 1 or -1; for dX = -1, 1, 2 do
        local x, y = tX + dX, tY + pD; if x >= 1 and x <= 8 and y >= 1 and y <= 8 then
            local p = board[y][x]; if p and p.type == "pawn" and p.color == attColor then return true end
        end
    end; local kO = { { 1, 2 }, { 1, -2 }, { -1, 2 }, { -1, -2 }, { 2, 1 }, { 2, -1 }, { -2, 1 }, { -2, -1 } }; for _, o in ipairs(kO) do
        local x, y = tX + o[1], tY + o[2]; if x >= 1 and x <= 8 and y >= 1 and y <= 8 then
            local p = board[y][x]; if p and p.type == "knight" and p.color == attColor then return true end
        end
    end; local sD = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 }, { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }; for i, d in ipairs(sD) do
        for dist = 1, 7 do
            local x, y = tX + d[1] * dist, tY + d[2] * dist; if x >= 1 and x <= 8 and y >= 1 and y <= 8 then
                local p = board[y][x]; if p then
                    if p.color == attColor then if i <= 4 and (p.type == "rook" or p.type == "queen") then return true elseif i > 4 and (p.type == "bishop" or p.type == "queen") then return true end end; break
                end
            else
                break
            end
        end
    end; local Kof = { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 }, { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }; for _, o in ipairs(Kof) do
        local x, y = tX + o[1], tY + o[2]; if x >= 1 and x <= 8 and y >= 1 and y <= 8 then
            local p = board[y][x]; if p and p.type == "king" and p.color == attColor then return true end
        end
    end; return false
end

function isKingInCheck(kColor)
    local kP = findKing(kColor); if not kP then return true end; return isSquareAttacked(kP.x, kP.y,
        (kColor == "white") and "black" or "white")
end

function isMoveValid(x, y, mL)
    for _, m in ipairs(mL) do if m.x == x and m.y == y then return m end end; return nil
end

function getValidPawnMoves(p, sX, sY)
    local m, d = {}, (p.color == "white") and -1 or 1; local oY = sY + d; if oY >= 1 and oY <= 8 and not board[oY][sX] then
        table.insert(m, { x = sX, y = oY }); if not p.hasMoved and not board[sY + 2 * d][sX] then
            table.insert(m,
                { x = sX, y = sY + 2 * d })
        end
    end; for dX = -1, 1, 2 do
        local nX, nY = sX + dX, sY + d; if nX >= 1 and nX <= 8 and nY >= 1 and nY <= 8 then
            local t = board[nY][nX]; if t and t.color ~= p.color then table.insert(m, { x = nX, y = nY }) end
        end
    end; if gameState.enPassantTarget then
        for dX = -1, 1, 2 do
            if sX + dX == gameState.enPassantTarget.x and sY + d == gameState.enPassantTarget.y then
                table.insert(m, { x = gameState.enPassantTarget.x, y = gameState.enPassantTarget.y, isEnPassant = true })
            end
        end
    end; return
        m
end

function getValidSlidingMoves(p, sX, sY, dirs)
    local m = {}; for _, d in ipairs(dirs) do
        for i = 1, 7 do
            local nX, nY = sX + d[1] * i, sY + d[2] * i; if nX >= 1 and nX <= 8 and nY >= 1 and nY <= 8 then
                local t = board[nY][nX]; if not t then
                    table.insert(m, { x = nX, y = nY })
                else
                    if t.color ~= p.color then table.insert(m, { x = nX, y = nY }) end; break
                end
            else
                break
            end
        end
    end; return m
end

function getValidRookMoves(p, sX, sY) return getValidSlidingMoves(p, sX, sY, { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) end; function getValidBishopMoves(
    p, sX, sY)
    return getValidSlidingMoves(p, sX, sY, { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } })
end; function getValidQueenMoves(
    p, sX, sY)
    local m = getValidRookMoves(p, sX, sY); for _, bm in ipairs(getValidBishopMoves(p, sX, sY)) do table.insert(m, bm) end; return
        m
end

function getValidKnightMoves(p, sX, sY)
    local m, o = {}, { { 1, 2 }, { 1, -2 }, { -1, 2 }, { -1, -2 }, { 2, 1 }, { 2, -1 }, { -2, 1 }, { -2, -1 } }; for _, of in ipairs(o) do
        local nX, nY = sX + of[1], sY + of[2]; if nX >= 1 and nX <= 8 and nY >= 1 and nY <= 8 then
            local t = board[nY][nX]; if not t or t.color ~= p.color then table.insert(m, { x = nX, y = nY }) end
        end
    end; return m
end

function getValidKingMoves(p, sX, sY)
    local m, o = {}, { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 }, { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }; for _, of in ipairs(o) do
        local nX, nY = sX + of[1], sY + of[2]; if nX >= 1 and nX <= 8 and nY >= 1 and nY <= 8 then
            local t = board[nY][nX]; if not t or t.color ~= p.color then table.insert(m, { x = nX, y = nY }) end
        end
    end; if not p.hasMoved and not isKingInCheck(p.color) then
        local opp = (p.color == "white") and "black" or "white"; local rk = board[sY][8]; if rk and rk.type == "rook" and not rk.hasMoved and not board[sY][6] and not board[sY][7] and not isSquareAttacked(6, sY, opp) and not isSquareAttacked(7, sY, opp) then
            table.insert(m, { x = 7, y = sY, isCastling = true })
        end; local rq = board[sY][1]; if rq and rq.type == "rook" and not rq.hasMoved and not board[sY][2] and not board[sY][3] and not board[sY][4] and not isSquareAttacked(3, sY, opp) and not isSquareAttacked(4, sY, opp) then
            table.insert(m, { x = 3, y = sY, isCastling = true })
        end
    end; return m
end

-- SEÇÃO 3: FUNÇÕES AUXILIARES DE DADOS E CONFIGURAÇÃO
function startNewGame()
    gameState = { state = "playing", turn = "white", selectedPiece = nil, validMoves = {}, promotionSquare = nil, winner = nil, enPassantTarget = nil, history = {} }; setupBoard(); local fen =
        generateFEN(); gameState.history[fen] = 1; print("Novo jogo iniciado.")
end

function createPiece(type, color) return { type = type, color = color, hasMoved = false } end

function findKing(kColor)
    for y = 1, 8 do
        for x = 1, 8 do
            local p = board[y][x]; if p and p.type == "king" and p.color == kColor then return { x = x, y = y } end
        end
    end
end

function loadPieceImages()
    pieceImages = {}; local p, c = { "P", "R", "N", "B", "Q", "K" }, { "w", "b" }; for _, cl in ipairs(c) do
        for _, pc in ipairs(p) do
            local k = cl .. pc; pieceImages[k] = love.graphics.newImage("assets/" .. k .. ".png")
        end
    end
end

function setupBoard()
    board = {}; for y = 1, 8 do board[y] = {} end; local r = { "rook", "knight", "bishop", "queen", "king", "bishop",
        "knight", "rook" }; for x = 1, 8 do
        board[1][x] = createPiece(r[x], "black"); board[2][x] = createPiece("pawn", "black"); board[7][x] = createPiece(
            "pawn", "white"); board[8][x] = createPiece(r[x], "white")
    end
end

function coordToAlgebraic(coord)
    if not coord then return "-" end; local f = { "a", "b", "c", "d", "e", "f", "g", "h" }; return f[coord.x] ..
        (8 - (coord.y - 1))
end

function generateFEN()
    local fen = ""; for y = 1, 8 do
        local e = 0; for x = 1, 8 do
            local p = board[y][x]; if p then
                if e > 0 then
                    fen = fen .. e; e = 0
                end; local l = string.upper(string.sub(p.type, 1, 1)); if p.type == "knight" then l = "N" end; if p.color == "black" then
                    l =
                        string.lower(l)
                end; fen = fen .. l
            else
                e = e + 1
            end
        end; if e > 0 then fen = fen .. e end; if y < 8 then fen = fen .. "/" end
    end; fen = fen .. " " .. string.sub(gameState.turn, 1, 1); local cR = ""; local wk, wrk, wrq = board[8][5],
        board[8][8], board[8][1]; local bk, brk, brq = board[1][5], board[1][8], board[1][1]; if wk and wk.type == "king" and not wk.hasMoved then
        if wrk and wrk.type == "rook" and not wrk.hasMoved then cR = cR .. "K" end; if wrq and wrq.type == "rook" and not wrq.hasMoved then
            cR =
                cR .. "Q"
        end
    end; if bk and bk.type == "king" and not bk.hasMoved then
        if brk and brk.type == "rook" and not brk.hasMoved then cR = cR .. "k" end; if brq and brq.type == "rook" and not brq.hasMoved then
            cR =
                cR .. "q"
        end
    end; if cR == "" then cR = "-" end; fen = fen .. " " .. cR; fen = fen ..
        " " .. coordToAlgebraic(gameState.enPassantTarget); return fen
end

-- SEÇÃO 4: FUNÇÕES AUXILIARES DE DESENHO
function drawBoard()
    for y = 1, 8 do
        for x = 1, 8 do
            if (x + y) % 2 == 0 then love.graphics.setColor(.9, .9, .9) else love.graphics.setColor(.4, .4, .5) end;
            love.graphics.rectangle("fill", (x - 1) * squareSize, (y - 1) * squareSize, squareSize, squareSize)
        end
    end
end

function drawHighlights()
    if gameState.selectedPiece then
        local s = gameState.selectedPiece; love.graphics.setColor(0, 1, 0, .4); love.graphics.rectangle("fill",
            (s.x - 1) * squareSize, (s.y - 1) * squareSize, squareSize, squareSize); love.graphics.setColor(1, 1, 0, .5); for _, m in ipairs(gameState.validMoves) do
            love.graphics.rectangle("fill", (m.x - 1) * squareSize, (m.y - 1) * squareSize, squareSize, squareSize)
        end
    end
end

function drawPieces()
    love.graphics.setColor(1, 1, 1); for y = 1, 8 do
        for x = 1, 8 do
            local p = board[y][x]; if p then
                local pi = string.upper(string.sub(p.type, 1, 1)); if p.type == "knight" then pi = "N" end; local k =
                    string.sub(p.color, 1, 1) .. pi; local img = pieceImages[k]; if img then
                    love.graphics.draw(img,
                        (x - 1) * squareSize, (y - 1) * squareSize, 0, 90 / img:getWidth())
                end
            end
        end
    end
end

function drawPromotionUI()
    local w, h = 800, 800; local c = { "queen", "rook", "bishop", "knight" }; local t = gameState.turn; love.graphics
        .setColor(0, 0, 0, .7); love.graphics.rectangle("fill", 0, 0, w, h); local sX, sY = (w - squareSize * #c) / 2,
        (h - squareSize) / 2; for i, ch in ipairs(c) do
        local k = string.sub(t, 1, 1) .. string.upper(string.sub(ch, 1, 1)); if ch == "knight" then
            k = string.sub(t, 1,
                1) .. "N"
        end; local img = pieceImages[k]; love.graphics.setColor(1, 1, 1); if img then
            love.graphics
                .draw(img, sX + (i - 1) * squareSize, sY, 0, squareSize / img:getWidth())
        end
    end
end

function drawGameOverUI()
    local w, h = 800, 800; local msg; if gameState.winner == "Draw" then
        msg = "Empate por Afogamento!"
    elseif gameState.winner == "Draw by Repetition" then
        msg =
        "Empate por Repetição!"
    else
        msg = "Xeque-Mate!\n" .. gameState.winner .. " vence!"
    end; love.graphics.setColor(
        0, 0, 0, .7); love.graphics.rectangle("fill", 0, 0, w, h); local font = love.graphics.newFont(40); love.graphics
        .setFont(font); love.graphics.setColor(1, 1, 1); love.graphics.printf(msg, 0, h / 2 - font:getHeight(), w,
        "center"); local smallFont = love.graphics.newFont(20); love.graphics.setFont(smallFont); love.graphics.printf(
        "Clique para reiniciar", 0, h / 2 + font:getHeight(), w, "center")
end
