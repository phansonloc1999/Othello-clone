---@class Board
Board = Class {}

local CELL_WIDTH, CELL_HEIGHT = 50, 50
BOARD_SIZES = {
    small = {row = 4, column = 4},
    medium = {row = 6, column = 6},
    big = {row = 8, column = 8}
}

function Board:init(size, numOfPlayer)
    self._matrix = {}
    self._currentCollider = nil
    self._possibleMoves = {}
    self._size = size
    self._row, self._column = BOARD_SIZES[size].row, BOARD_SIZES[size].column
    self._anchorX, self._anchorY =
        WINDOW_WIDTH / 2 - self._row * CELL_WIDTH / 2,
        WINDOW_HEIGHT / 2 - self._column * CELL_HEIGHT / 2 + 10

    for i = 1, self._row do
        self._matrix[i] = {}
        for j = 1, self._column do
            self._matrix[i][j] = 0
        end
    end

    -- Default moves initialization
    self._matrix[self._row / 2][self._column / 2 + 1] = 1
    self._matrix[self._row / 2 + 1][self._column / 2] = 1
    self._matrix[self._row / 2][self._column / 2] = 2
    self._matrix[self._row / 2 + 1][self._column / 2 + 1] = 2

    self:getAllPossibleMoves()

    self._numOfPlayer = numOfPlayer

    self._units = {
        black = love.graphics.newImage("assets/Board/Black.png"),
        hint = love.graphics.newImage("assets/Board/Hint.png"),
        white = love.graphics.newImage("assets/Board/White.png")
    }

    self._tile = love.graphics.newImage("assets/Board/Tile.png")

    self._turningAnimations = {
        blackToWhite = Animation(
            {
                love.graphics.newImage("assets/Board/Animations/BlackToWhite/1.png"),
                love.graphics.newImage("assets/Board/Animations/BlackToWhite/2.png"),
                love.graphics.newImage("assets/Board/Animations/BlackToWhite/3.png"),
                love.graphics.newImage("assets/Board/Animations/BlackToWhite/4.png")
            },
            {0.1, 0.1, 0.1}
        ),
        whiteToBlack = Animation(
            {
                love.graphics.newImage("assets/Board/Animations/WhiteToBlack/1.png"),
                love.graphics.newImage("assets/Board/Animations/WhiteToBlack/2.png"),
                love.graphics.newImage("assets/Board/Animations/WhiteToBlack/3.png"),
                love.graphics.newImage("assets/Board/Animations/WhiteToBlack/4.png")
            },
            {0.1, 0.1, 0.1}
        )
    }

    self._delayAIanimationTimer = 0
    self._delayAIDecisionTimer = 0
end

function Board:render()
    for i = 1, self._row do
        for j = 1, self._column do
            --- Render tile
            love.graphics.draw(self._tile, self._anchorX + CELL_WIDTH * (j - 1), self._anchorY + CELL_HEIGHT * (i - 1))

            --- If this unit is in turning animation, stop rendering it
            if (not self._unitsTurningOver or not belongsTo(self._unitsTurningOver, {i, j})) then
                if (self._matrix[i][j] == 1) then -- Black
                    love.graphics.draw(
                        self._units.black,
                        self._anchorX + CELL_WIDTH * (j - 1) + CELL_WIDTH / 2 -
                            math.floor(self._units.black:getWidth() / 2),
                        self._anchorY + CELL_HEIGHT * (i - 1) + CELL_HEIGHT / 2 -
                            math.floor(self._units.black:getHeight() / 2)
                    )
                elseif (self._matrix[i][j] == 2) then -- White
                    love.graphics.draw(
                        self._units.white,
                        self._anchorX + CELL_WIDTH * (j - 1) + CELL_WIDTH / 2 -
                            math.floor(self._units.black:getWidth() / 2),
                        self._anchorY + CELL_HEIGHT * (i - 1) + CELL_HEIGHT / 2 -
                            math.floor(self._units.black:getHeight() / 2)
                    )
                end
            end
        end
    end

    -- If player vs COM, do not render AI's possible move hints
    if CURRENT_PLAYER_TURN ~= 2 or self._numOfPlayer ~= 1 then
        for k, move in ipairs(self._possibleMoves) do
            self._currentCollider =
                Collider(
                self._anchorX + CELL_WIDTH * (move[2] - 1),
                self._anchorY + CELL_HEIGHT * (move[1] - 1),
                CELL_WIDTH,
                CELL_HEIGHT
            )
            --- Hovering mouse above a move render a current player unit on that tile
            if (self._currentCollider:checkCollisionWithCursor()) then
                if (CURRENT_PLAYER_TURN == 1) then
                    love.graphics.draw(
                        self._units.black,
                        self._anchorX + CELL_WIDTH * (move[2] - 1) + CELL_WIDTH / 2 -
                            math.floor(self._units.hint:getWidth() / 2),
                        self._anchorY + CELL_HEIGHT * (move[1] - 1) + CELL_HEIGHT / 2 -
                            math.floor(self._units.hint:getHeight() / 2)
                    )
                else
                    love.graphics.draw(
                        self._units.white,
                        self._anchorX + CELL_WIDTH * (move[2] - 1) + CELL_WIDTH / 2 -
                            math.floor(self._units.hint:getWidth() / 2),
                        self._anchorY + CELL_HEIGHT * (move[1] - 1) + CELL_HEIGHT / 2 -
                            math.floor(self._units.hint:getHeight() / 2)
                    )
                end
            else
                --- Render hints
                love.graphics.draw(
                    self._units.hint,
                    self._anchorX + CELL_WIDTH * (move[2] - 1) + CELL_WIDTH / 2 -
                        math.floor(self._units.hint:getWidth() / 2),
                    self._anchorY + CELL_HEIGHT * (move[1] - 1) + CELL_HEIGHT / 2 -
                        math.floor(self._units.hint:getHeight() / 2)
                )
            end
        end
    end

    if (self._unitsTurningOver) then
        if (CURRENT_PLAYER_TURN == 1) then
            self._turningAnimations.whiteToBlack:render()
        else
            self._turningAnimations.blackToWhite:render()
        end
    end

    if (self._lastAIMove) then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle(
            "line",
            self._anchorX + CELL_WIDTH * (self._lastAIMove[2] - 1),
            self._anchorY + CELL_HEIGHT * (self._lastAIMove[1] - 1),
            50,
            50
        )
        love.graphics.setColor(1, 1, 1)
    end
end

function Board:update(dt)
    if (#self._possibleMoves == 0 and not self._scoreStateTimer) then
        CURRENT_PLAYER_TURN = CURRENT_PLAYER_TURN == 1 and 2 or 1
        self:getAllPossibleMoves()
        if (#self._possibleMoves == 0) then
            self._scoreStateTimer = 2
        end
    end

    if (self._scoreStateTimer) then
        print(self._scoreStateTimer)
        if (self._scoreStateTimer > 0) then
            self._scoreStateTimer = self._scoreStateTimer - dt
        else
            local params = self:getWinner()
            params.size = self._size
            params.numOfPlayer = self._numOfPlayer
            gStateMachine:change("score", params)
        end
    end

    -- AI makes a move
    if
        (self._numOfPlayer == 1) and (CURRENT_PLAYER_TURN == 2) and not self._unitsTurningOver and
            (self._delayAIDecisionTimer <= 0)
     then
        self:getAllPossibleMoves()
        if (#self._possibleMoves > 0) then
            AudioManager.stop("move")
            AudioManager.play("move")

            local index = math.random(1, #self._possibleMoves)
            local row, column = self._possibleMoves[index][1], self._possibleMoves[index][2]
            self._lastAIMove = {row, column}

            self._matrix[row][column] = CURRENT_PLAYER_TURN
            -- Get a table of rows and columns of turned over units
            self._unitsTurningOver = self:turnOverAt(row, column)
            -- Get animation positions for rendering using rows and columns
            local positions = self:getAnimationPositions()
            -- Current player (AI) is white, start animation white to black
            self._turningAnimations.blackToWhite:setPositions(positions)

            self._delayAIanimationTimer = 2
            return
        end
    end

    -- If AI making a move, stop player from interfering with that
    if (self._numOfPlayer ~= 1 or CURRENT_PLAYER_TURN ~= 2) then
        -- Player makes a move
        for i = 1, self._row do
            for j = 1, self._column do
                self._currentCollider =
                    Collider(
                    self._anchorX + CELL_WIDTH * (j - 1),
                    self._anchorY + CELL_HEIGHT * (i - 1),
                    CELL_WIDTH,
                    CELL_HEIGHT
                )
                if (self._currentCollider:checkCollisionWithCursor()) then
                    if (love.mouse.wasPressed(1) and belongsTo(self._possibleMoves, {i, j})) then
                        self._matrix[i][j] = CURRENT_PLAYER_TURN

                        -- Get a table of rows and columns of turned over units
                        self._unitsTurningOver = self:turnOverAt(i, j)
                        -- Get animation positions for rendering using rows and columns
                        local positions = self:getAnimationPositions()

                        -- If current player is black, start animation white to black
                        if (CURRENT_PLAYER_TURN == 1) then
                            self._turningAnimations.whiteToBlack:setPositions(positions)
                            if (self._numOfPlayer == 1) then
                                self._delayAIDecisionTimer = 1.5
                            end
                        else
                            self._turningAnimations.blackToWhite:setPositions(positions)
                        end
                        AudioManager.play("move")
                        return
                    end
                end
            end
        end
    end

    if (self._delayAIanimationTimer >= 0) then
        self._delayAIanimationTimer = math.max(0, self._delayAIanimationTimer - dt)
    end

    if (self._delayAIanimationTimer == 0) then
        self:updateTurningAnimations(dt)
    end

    if (self._delayAIDecisionTimer >= 0) then
        self._delayAIDecisionTimer = math.max(0, self._delayAIDecisionTimer - dt)
    end
end

function Board:getPossibleMovesAt(row, column)
    local index = column - 1
    while (self._matrix[row][index] ~= CURRENT_PLAYER_TURN and self._matrix[row][index] ~= 0 and index >= 2) do
        index = index - 1
    end
    if (self._matrix[row][index] == 0 and index + 1 ~= column) then
        table.insert(self._possibleMoves, {row, index})
    end

    index = column + 1
    while (self._matrix[row][index] ~= CURRENT_PLAYER_TURN and self._matrix[row][index] ~= 0 and
        index <= self._column - 1) do
        index = index + 1
    end
    if (self._matrix[row][index] == 0 and index - 1 ~= column) then
        table.insert(self._possibleMoves, {row, index})
    end

    index = row - 1
    while (index >= 2 and self._matrix[index][column] ~= CURRENT_PLAYER_TURN and self._matrix[index][column] ~= 0) do
        index = index - 1
    end
    if (index + 1 ~= row and self._matrix[index][column] == 0) then
        table.insert(self._possibleMoves, {index, column})
    end

    index = row + 1
    while (index <= self._row - 1 and self._matrix[index][column] ~= CURRENT_PLAYER_TURN and
        self._matrix[index][column] ~= 0) do
        index = index + 1
    end
    if (index - 1 ~= row and self._matrix[index][column] == 0) then
        table.insert(self._possibleMoves, {index, column})
    end

    -- Get 2 diagonal possible moves
    -- Left diagonal
    --- Upper part
    if (row > 1 and column > 1) then
        -- Iterate diagonally from right to left
        local rowIter, columnIter = row - 1, column - 1
        while (rowIter > 1 and columnIter > 1 and self._matrix[rowIter][columnIter] ~= CURRENT_PLAYER_TURN and
            self._matrix[rowIter][columnIter] ~= 0) do
            rowIter, columnIter = rowIter - 1, columnIter - 1
        end
        if (self._matrix[rowIter][columnIter] == 0 and rowIter ~= row - 1 and columnIter ~= column - 1) then
            table.insert(self._possibleMoves, {rowIter, columnIter})
        end
    end
    --- Lower part
    if (row < self._row and column < self._column) then
        -- Iterate diagonally from left to right
        local rowIter, columnIter = row + 1, column + 1
        while (rowIter < self._row and columnIter < self._column and
            self._matrix[rowIter][columnIter] ~= CURRENT_PLAYER_TURN and
            self._matrix[rowIter][columnIter] ~= 0) do
            rowIter, columnIter = rowIter + 1, columnIter + 1
        end
        if (self._matrix[rowIter][columnIter] == 0 and rowIter ~= row + 1 and columnIter ~= column + 1) then
            table.insert(self._possibleMoves, {rowIter, columnIter})
        end
    end
    -- Right diagonal
    --- Upper part
    if (row > 1 and column < self._column) then
        -- Iterate diagonally from left to right
        local rowIter, columnIter = row - 1, column + 1
        while (rowIter > 1 and columnIter > 1 and self._matrix[rowIter][columnIter] ~= CURRENT_PLAYER_TURN and
            self._matrix[rowIter][columnIter] ~= 0) do
            rowIter, columnIter = rowIter - 1, columnIter + 1
        end
        if (self._matrix[rowIter][columnIter] == 0 and rowIter ~= row - 1 and columnIter ~= column + 1) then
            table.insert(self._possibleMoves, {rowIter, columnIter})
        end
    end
    --- Lower part
    if (row < self._row and column > 1) then
        -- Iterate diagonally from right to left
        local rowIter, columnIter = row + 1, column - 1
        while (rowIter < self._row and columnIter < self._column and
            self._matrix[rowIter][columnIter] ~= CURRENT_PLAYER_TURN and
            self._matrix[rowIter][columnIter] ~= 0) do
            rowIter, columnIter = rowIter + 1, columnIter - 1
        end
        if (self._matrix[rowIter][columnIter] == 0 and rowIter ~= row + 1 and columnIter ~= column - 1) then
            table.insert(self._possibleMoves, {rowIter, columnIter})
        end
    end
end

function Board:getAllPossibleMoves()
    for i = 1, self._row do
        for j = 1, self._column do
            if (self._matrix[i][j] == CURRENT_PLAYER_TURN) then
                self:getPossibleMovesAt(i, j)
            end
        end
    end
end

function Board:turnOverAt(row, column)
    local turnedOver = {}
    local first, last
    for i = 1, self._column do
        if (self._matrix[row][i] == CURRENT_PLAYER_TURN) then
            first = i
            local j = i + 1
            while (self._matrix[row][j] ~= CURRENT_PLAYER_TURN and self._matrix[row][j] ~= 0 and j <= self._column) do
                j = j + 1
            end
            if (self._matrix[row][j] == CURRENT_PLAYER_TURN) then
                last = j
            elseif (self._matrix[row][j] == 0) then
                first, last = nil, nil
            end

            if (first and last and first < last and (first == column or last == column)) then
                for j = first + 1, last - 1 do
                    self._matrix[row][j] = CURRENT_PLAYER_TURN
                    table.insert(turnedOver, {row, j})
                end
            end
        end
    end

    for i = 1, self._row do
        if (self._matrix[i][column] == CURRENT_PLAYER_TURN) then
            first = i
            local j = i + 1
            while (j <= self._row and self._matrix[j][column] ~= CURRENT_PLAYER_TURN and self._matrix[j][column] ~= 0) do
                j = j + 1
            end
            if (j <= self._row) then
                if (self._matrix[j][column] == CURRENT_PLAYER_TURN) then
                    last = j
                elseif (self._matrix[j][column] == 0) then
                    first, last = nil, nil
                end

                if (first and last and first < last and (first == row or last == row)) then
                    for j = first + 1, last - 1 do
                        self._matrix[j][column] = CURRENT_PLAYER_TURN
                        table.insert(turnedOver, {j, column})
                    end
                end
            end
        end
    end

    local beginRow, beginColumn = row, column
    -- Find left most positions of diagonal
    while (beginRow > 1 and beginColumn > 1) do
        beginRow, beginColumn = beginRow - 1, beginColumn - 1
    end
    while (beginRow < self._row and beginColumn < self._column) do
        -- If current unit is current player's move, turn over inbetween opponent's units
        if (self._matrix[beginRow][beginColumn] == CURRENT_PLAYER_TURN) then
            -- Find right nearest symetrical current player's move vertically
            local endRow, endColumn = beginRow + 1, beginColumn + 1
            while (endRow < self._row and endColumn < self._column and
                self._matrix[endRow][endColumn] ~= CURRENT_PLAYER_TURN and
                self._matrix[endRow][endColumn] ~= 0) do
                endRow, endColumn = endRow + 1, endColumn + 1
            end
            -- If end and begin unit is recent player's move
            if
                ((endRow == row and endColumn == column) or
                    (beginRow == row and beginColumn == column) and self._matrix[endRow][endColumn] ~= 0)
             then
                beginRow, beginColumn = beginRow + 1, beginColumn + 1
                while (beginRow < endRow and beginColumn < endColumn) do
                    table.insert(turnedOver, {beginRow, beginColumn})
                    self._matrix[beginRow][beginColumn] = CURRENT_PLAYER_TURN
                    beginRow, beginColumn = beginRow + 1, beginColumn + 1
                end
                beginRow, beginColumn = endRow - 1, endColumn - 1
            end
        end
        -- check next unit on the right of the same diagonal
        beginRow, beginColumn = beginRow + 1, beginColumn + 1
    end

    beginRow, beginColumn = row, column
    -- Find right most positions of diagonal
    while (beginRow > 1 and beginColumn < self._column) do
        beginRow, beginColumn = beginRow - 1, beginColumn + 1
    end
    while (beginRow < self._row and beginColumn > 1) do
        -- If current unit is current player's move, turn over inbetween opponent's units
        if (self._matrix[beginRow][beginColumn] == CURRENT_PLAYER_TURN) then
            -- Find left nearest symetrical current player's move vertically
            local endRow, endColumn = beginRow + 1, beginColumn - 1
            while (endRow < self._row and endColumn > 1 and self._matrix[endRow][endColumn] ~= CURRENT_PLAYER_TURN and
                self._matrix[endRow][endColumn] ~= 0) do
                endRow, endColumn = endRow + 1, endColumn - 1
            end
            if
                ((endRow == row and endColumn == column) or
                    (beginRow == row and beginColumn == column) and self._matrix[endRow][endColumn] ~= 0)
             then
                beginRow, beginColumn = beginRow + 1, beginColumn - 1
                while (beginRow < endRow and beginColumn > endColumn) do
                    table.insert(turnedOver, {beginRow, beginColumn})
                    self._matrix[beginRow][beginColumn] = CURRENT_PLAYER_TURN
                    beginRow, beginColumn = beginRow + 1, beginColumn - 1
                end
                beginRow, beginColumn = endRow - 1, endColumn + 1
            end
        end
        -- check left next unit of the same diagonal
        beginRow, beginColumn = beginRow + 1, beginColumn - 1
    end

    return turnedOver
end

function Board:getWinner()
    local result = self:getScores()
    if (result[1] > result[2]) then
        result.winner = 1
        return result
    elseif (result[2] > result[1]) then
        result.winner = 2
        return result
    end
    result.winner = "draw"
    return result
end

function Board:getScores()
    local player1Moves, player2Moves = 0, 0
    for i = 1, self._row do
        for j = 1, self._column do
            if (self._matrix[i][j] == 1) then
                player1Moves = player1Moves + 1
            elseif (self._matrix[i][j] == 2) then
                player2Moves = player2Moves + 1
            end
        end
    end
    return {player1Moves, player2Moves}
end

function Board:getAnimationPositions()
    local result = {}
    for i = 1, #self._unitsTurningOver do
        table.insert(
            result,
            {
                self._anchorX + CELL_WIDTH * (self._unitsTurningOver[i][2] - 1) + CELL_WIDTH / 2 -
                    math.floor(self._units.black:getWidth() / 2),
                self._anchorY + CELL_HEIGHT * (self._unitsTurningOver[i][1] - 1) + CELL_HEIGHT / 2 -
                    math.floor(self._units.black:getHeight() / 2)
            }
        )
    end
    return result
end

function Board:updateTurningAnimations(dt)
    if (self._unitsTurningOver) then
        if (CURRENT_PLAYER_TURN == 1) then
            self._turningAnimations.whiteToBlack:update(dt)

            if (self._turningAnimations.whiteToBlack:isFinished()) then
                self._unitsTurningOver = nil
                CURRENT_PLAYER_TURN = CURRENT_PLAYER_TURN == 1 and 2 or 1
                self._possibleMoves = {}
                self:getAllPossibleMoves()
                self._turningAnimations.whiteToBlack:reset()
            end
        else
            self._turningAnimations.blackToWhite:update(dt)
            if (self._turningAnimations.blackToWhite:isFinished()) then
                self._unitsTurningOver = nil
                CURRENT_PLAYER_TURN = CURRENT_PLAYER_TURN == 1 and 2 or 1
                self._possibleMoves = {}
                self:getAllPossibleMoves()
                self._turningAnimations.blackToWhite:reset()
            end
        end
    end
end
