---@class MenuState
MenuState = Class {__includes = BaseState}

LARGE_DEFAULT_FONT = love.graphics.newFont(25)
DEFAULT_FONT = love.graphics.setNewFont(12)

function MenuState:init()
    self._playButton =
        RectButton(
        getCenterX(love.graphics.getWidth(), 100),
        getCenterY(love.graphics.getHeight(), 30) + 20,
        100,
        30,
        "Play",
        gColors.WHITE
    )

    local aboutButtonX, aboutButtonY = getPositionsWithOffsets(self._playButton._boxX, self._playButton._boxY, 0, 50)
    self._aboutButton =
        RectButton(
        aboutButtonX,
        aboutButtonY,
        self._playButton._boxWidth,
        self._playButton._boxHeight,
        "About",
        gColors.WHITE
    )

    local quitButtonX, quitButtonY = getPositionsWithOffsets(self._aboutButton._boxX, self._aboutButton._boxY, 0, 50)
    self._quitButton =
        RectButton(
        quitButtonX,
        quitButtonY,
        self._aboutButton._boxWidth,
        self._aboutButton._boxHeight,
        "Quit",
        gColors.WHITE
    )

    self._gameTitle = Text(0, 0, "OTHELLO", LARGE_DEFAULT_FONT)
    self._gameTitle:setPos(
        love.graphics.getWidth() / 2 - self._gameTitle._text:getWidth() / 2,
        love.graphics.getHeight() / 3
    )
end

function MenuState:render()
    self._playButton:render()
    self._aboutButton:render()
    self._quitButton:render()
    self._gameTitle:render()
end

function MenuState:update(dt)
    if (love.mouse.wasPressed(1)) then
        if (self._quitButton:collidesWithMouse()) then
            love.event.quit()
        end
        if (self._playButton:collidesWithMouse()) then
            gStateMachine:change("play")
        end
    end
end
