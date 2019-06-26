---@class Board
Board = Class {}

local CELL_WIDTH, CELL_HEIGHT = 50, 50
local BOARD_SIZES = {
    small = {row = 4, column = 4},
    medium = {row = 6, column = 6},
    big = {row = 8, column = 8}
}

function Board:init(size, numOfPlayer)
    self._matrix = {}
    self._currentCollider = nil
    self._possibleMoves = {}
    self._size = BOARD_SIZES[size]
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

    if (self._unitsTurningOver) then
        if (CURRENT_PLAYER_TURN == 1) then
            self._turningAnimations.whiteToBlack:render()
        else
            self._turningAnimations.blackToWhite:render()
        end
    end
end

function Board:update(dt)
    if (#self._possibleMoves == 0) then
        CURRENT_PLAYER_TURN = CURRENT_PLAYER_TURN == 1 and 2 or 1
        self:getAllPossibleMoves()
        if (#self._possibleMoves == 0) then
            gStateMachine:change("score", self:getWinner())
        end
    end

    -- AI makes a move
    if (self._numOfPlayer == 1) and (CURRENT_PLAYER_TURN == 2) and not self._unitsTurningOver then
        self:getAllPossibleMoves()
        if (#self._possibleMoves > 0) then
            local index = math.random(1, #self._possibleMoves)
            local row, column = self._possibleMoves[index][1], self._possibleMoves[index][2]

            self._matrix[row][column] = CURRENT_PLAYER_TURN
            -- Get a table of rows and columns of turned over units
            self._unitsTurningOver = self:turnOverAt(row, column)
            -- Get animation positions for rendering using rows and columns
            local positions = self:getAnimationPositions()
            -- Current player (AI) is white, start animation white to black
            self._turningAnimations.blackToWhite:setPositions(positions)
            return
        end
    end

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
                    else
                        self._turningAnimations.blackToWhite:setPositions(positions)
                    end
                    return
                end
            end
        end
    end

    self:updateTurningAnimations(dt)
end

function Board:getPossibleMovesAt(row, column)
    local index = column - 1
    while (self._matrix[row][index] ~= CURRENT_PLAYER_TURN and self._matrix[row][index] ~= 0 and index >= 2) do
        index = index - 1
    end
    if (self._matrix[row][index] == 0 and index + 1 ~= column) then
        table.insert(self._possibleMoves, {row, index})
    end

    local index = column + 1
    while (self._matrix[row][index] ~= CURRENT_PLAYER_TURN and self._matrix[row][index] ~= 0 and
        index <= self._column - 1) do
        index = index + 1
    end
    if (self._matrix[row][index] == 0 and index - 1 ~= column) then
        table.insert(self._possibleMoves, {row, index})
    end

    local index = row - 1
    while (index >= 2 and self._matrix[index][column] ~= CURRENT_PLAYER_TURN and self._matrix[index][column] ~= 0) do
        index = index - 1
    end
    if (index + 1 ~= row and self._matrix[index][column] == 0) then
        table.insert(self._possibleMoves, {index, column})
    end

    local index = row + 1
    while (index <= self._row - 1 and self._matrix[index][column] ~= CURRENT_PLAYER_TURN and
        self._matrix[index][column] ~= 0) do
        index = index + 1
    end
    if (index - 1 ~= row and self._matrix[index][column] == 0) then
        table.insert(self._possibleMoves, {index, column})
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
            if (not first) then
                first = i
            else
                last = i
            end
        elseif (self._matrix[row][i] == 0) then
            first, last = nil, nil
        end

        if (first and last and first < last) then
            for j = first + 1, last - 1 do
                self._matrix[row][j] = CURRENT_PLAYER_TURN
                table.insert(turnedOver, {row, j})
            end
        end
    end

    local first, last
    for i = 1, self._row do
        if (self._matrix[i][column] == CURRENT_PLAYER_TURN) then
            if (not first) then
                first = i
            else
                last = i
            end
        elseif (self._matrix[i][column] == 0) then
            first, last = nil, nil
        end

        if (first and last and first < last) then
            for j = first + 1, last - 1 do
                self._matrix[j][column] = CURRENT_PLAYER_TURN
                table.insert(turnedOver, {j, column})
            end
        end
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
