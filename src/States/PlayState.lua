---@class PlayState
PlayState = Class {__includes = BaseState}

local PLAY_WINDOW_WIDTH, PLAY_WINDOW_HEIGHT = 1000, 800

function PlayState:init()
    CURRENT_PLAYER_TURN = 1

    local buttonTexture = love.graphics.newImage("assets/Pause_deselected.png")
    self._pauseButton =
        RectButton(
        WINDOW_WIDTH / 2 - buttonTexture:getWidth() / 2,
        10,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/Pause_deselected.png", selected = "assets/Pause_selected.png"}
    )

    self._scoreBox = love.graphics.newImage("assets/ScoreBox.png")

    self._player1Score = {}
    local titleTexture = love.graphics.newImage("assets/Player1Title.png")
    self._player1Score.title = {
        texture = love.graphics.newImage("assets/Player1Title.png"),
        x = 20,
        y = 8
    }
    self._player1Score.valueBox = {
        texture = self._scoreBox,
        x = self._player1Score.title.x + self._player1Score.title.texture:getWidth() + 3,
        y = 11,
        score = 2
    }

    titleTexture = love.graphics.newImage("assets/Player2Title.png")
    self._player2Score = {}
    self._player2Score.title = {
        texture = love.graphics.newImage("assets/Player2Title.png"),
        x = WINDOW_WIDTH - titleTexture:getWidth() - 20,
        y = 8
    }
    self._player2Score.valueBox = {
        texture = self._scoreBox,
        x = self._player2Score.title.x - self._scoreBox:getWidth() - 3,
        y = 11,
        score = 2
    }

    self._comScore = {}
    self._comScore.title = {
        texture = love.graphics.newImage("assets/COMTitle.png"),
        x = WINDOW_WIDTH - titleTexture:getWidth() - 20,
        y = 8
    }
end

function PlayState:enter(params)
    if (params.pausedPlayState) then
        self._board = params.pausedPlayState._board
        self._player1Score.valueBox.score, self._player2Score.valueBox.score =
            params.pausedPlayState._player1Score.valueBox.score,
            params.pausedPlayState._player2Score.valueBox.score
    else
        self._board = Board(params.size, params.numOfPlayer)
    end
    self._size, self._numOfPlayer = params.size, params.numOfPlayer
end

function PlayState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gBackground.default)

    love.graphics.draw(self._player1Score.title.texture, self._player1Score.title.x, self._player1Score.title.y)
    love.graphics.draw(
        self._player1Score.valueBox.texture,
        self._player1Score.valueBox.x,
        self._player1Score.valueBox.y
    )
    local scoreText = love.graphics.newText(gFont, self._player1Score.valueBox.score)
    love.graphics.draw(
        scoreText,
        self._player1Score.valueBox.x + self._player1Score.valueBox.texture:getWidth() / 2 - scoreText:getWidth() / 2,
        self._player1Score.valueBox.y + self._player1Score.valueBox.texture:getHeight() / 2 - scoreText:getHeight() / 2
    )

    if (self._numOfPlayer == 1) then
        love.graphics.draw(self._comScore.title.texture, self._comScore.title.x, self._comScore.title.y)
    else
        love.graphics.draw(self._player2Score.title.texture, self._player2Score.title.x, self._player2Score.title.y)
    end

    love.graphics.draw(
        self._player2Score.valueBox.texture,
        self._player2Score.valueBox.x,
        self._player2Score.valueBox.y
    )
    local scoreText = love.graphics.newText(gFont, self._player2Score.valueBox.score)
    love.graphics.draw(
        scoreText,
        self._player2Score.valueBox.x + self._player2Score.valueBox.texture:getWidth() / 2 - scoreText:getWidth() / 2,
        self._player2Score.valueBox.y + self._player2Score.valueBox.texture:getHeight() / 2 - scoreText:getHeight() / 2
    )

    self._pauseButton:render()
    self._board:render()
end

function PlayState:update(dt)
    self._board:update(dt)

    if (self._pauseButton:collidesWithMouse() and not self._pauseButton._selected) then
        self._pauseButton:select()
    end
    if (not self._pauseButton:collidesWithMouse() and self._pauseButton._selected) then
        self._pauseButton:deselect()
    end

    if (love.mouse.wasPressed(1)) then
        if (self._pauseButton:collidesWithMouse()) then
            love.audio.play(gSounds.select)
            gStateMachine:change("pause", {pausedPlayState = self})
        end
    end

    self:updateScores()
end

function PlayState:updateScores()
    local score = self._board:getScores()
    self._player1Score.valueBox.score, self._player2Score.valueBox.score = score[1], score[2]
end
