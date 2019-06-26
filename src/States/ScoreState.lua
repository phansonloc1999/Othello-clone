---@class VictoryState
ScoreState = Class {__includes = BaseState}

function ScoreState:init()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    self._buttons = {}

    local texture = love.graphics.newImage("assets/Restart_deselected.png")
    self._buttons["restart"] =
        RectButton(
        getCenterX(0, WINDOW_WIDTH, texture:getWidth()),
        WINDOW_HEIGHT - 150,
        texture:getWidth(),
        texture:getHeight(),
        {deselected = "assets/Restart_deselected.png", selected = "assets/Restart_selected.png"},
        nil
    )

    texture = love.graphics.newImage("assets/Quit_deselected.png")
    local tempX, tempY = getPositionsWithOffsets(self._buttons.restart._boxX, self._buttons.restart._boxY, 0, 60)
    self._buttons["quit"] =
        RectButton(
        tempX,
        tempY,
        texture:getWidth(),
        texture:getHeight(),
        {deselected = "assets/Quit_deselected.png", selected = "assets/Quit_selected.png"},
        nil
    )

    texture = love.graphics.newImage("assets/Score/Win.png")
    self._resultTitle = {
        texture = texture,
        x = WINDOW_WIDTH / 2 - texture:getWidth() / 2,
        y = 30
    }

    texture = love.graphics.newImage("assets/Score/TotalScore.png")
    self._totalScore = {
        texture = texture,
        x = WINDOW_WIDTH / 2 - texture:getWidth() / 2,
        y = self._resultTitle.y + self._resultTitle.texture:getHeight() + 70
    }
end

function ScoreState:enter(params)
    self._player1Moves, self._player2Moves = params[1], params[2]
    self._numOfPlayer = params.numOfPlayer

    local font = love.graphics.newFont("assets/Font/font.ttf", 35)
    local text = love.graphics.newText(font, self._player1Moves .. " : " .. self._player2Moves)
    self._totalScore.text =
        Text(
        self._totalScore.x + self._totalScore.texture:getWidth() / 2 - text:getWidth() / 2,
        self._totalScore.y + self._totalScore.texture:getHeight() / 2 - text:getHeight() / 2,
        self._player1Moves .. " : " .. self._player2Moves,
        font,
        gColors.BLACK
    )

    local texture
    if (params.winner == 1) then
        texture = love.graphics.newImage("assets/Score/Player1Title.png")
        self._winnerTitle = {
            texture = texture,
            x = self._resultTitle.x + self._resultTitle.texture:getWidth() / 2 - texture:getWidth() / 2,
            y = self._resultTitle.y + self._resultTitle.texture:getHeight()
        }
    else
        if (params.winner == 2) then
            if (params.numOfPlayer == 1) then
                texture = love.graphics.newImage("assets/Score/Lose.png")
                self._resultTitle = {
                    texture = texture,
                    x = WINDOW_WIDTH / 2 - texture:getWidth() / 2,
                    y = 30
                }

                texture = love.graphics.newImage("assets/Score/ComTitle.png")
                self._winnerTitle = {
                    texture = texture,
                    x = self._resultTitle.x + self._resultTitle.texture:getWidth() / 2 - texture:getWidth() / 2,
                    y = self._resultTitle.y + self._resultTitle.texture:getHeight()
                }
            else
                texture = love.graphics.newImage("assets/Score/Win.png")
                self._resultTitle = {
                    texture = texture,
                    x = WINDOW_WIDTH / 2 - texture:getWidth() / 2,
                    y = 30
                }

                texture = love.graphics.newImage("assets/Score/Player2Title.png")
                self._winnerTitle = {
                    texture = texture,
                    x = self._resultTitle.x + self._resultTitle.texture:getWidth() / 2 - texture:getWidth() / 2,
                    y = self._resultTitle.y + self._resultTitle.texture:getHeight()
                }
            end
        elseif (params.winner == "draw") then
            texture = love.graphics.newImage("assets/Score/Draw.png")
            self._resultTitle = {
                texture = texture,
                x = WINDOW_WIDTH / 2 - texture:getWidth() / 2,
                y = 30
            }
        end
    end
end

function ScoreState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gBackground.default)

    love.graphics.draw(self._resultTitle.texture, self._resultTitle.x, self._resultTitle.y)
    if (self._winnerTitle) then
        love.graphics.draw(self._winnerTitle.texture, self._winnerTitle.x, self._winnerTitle.y)
    end
    love.graphics.draw(self._totalScore.texture, self._totalScore.x, self._totalScore.y)
    self._totalScore.text:render()

    for key, button in pairs(self._buttons) do
        button:render()
    end
end

function ScoreState:update(dt)
    for key, button in pairs(self._buttons) do
        if (button:collidesWithMouse() and button._selected == false) then
            button:select()
        end
        if (not button:collidesWithMouse() and button._selected == true) then
            button:deselect()
        end
    end

    if (love.mouse.wasPressed(1)) then
        if (self._buttons.restart:collidesWithMouse()) then
            gStateMachine:change("menu")
        end
        if (self._buttons.quit:collidesWithMouse()) then
            love.event.quit()
        end
    end
end
