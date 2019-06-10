---@class BoardState
BoardState = Class {__includes = BaseState}

local SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX = 80, 80
local BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT = 100, 30

function BoardState:init()
    self._smallButton =
        RectButton(
        WINDOW_WIDTH / 2 - 3 * SIZE_BUTTON_WIDTH / 2,
        WINDOW_HEIGHT / 2 - 3 * SIZE_BUTTON_BOX / 2,
        SIZE_BUTTON_WIDTH,
        SIZE_BUTTON_BOX,
        "Small"
    )

    local x, y = getPositionsWithOffsets(self._smallButton._boxX, self._smallButton._boxY, SIZE_BUTTON_WIDTH * 2, 0)
    self._mediumButton = RectButton(x, y, SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX, "Medium")

    x, y = getPositionsWithOffsets(self._smallButton._boxX, self._smallButton._boxY, 0, SIZE_BUTTON_BOX * 2)
    self._largeButton = RectButton(x, y, SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX, "Large")

    x, y =
        getPositionsWithOffsets(
        self._smallButton._boxX,
        self._smallButton._boxY,
        SIZE_BUTTON_WIDTH * 2,
        SIZE_BUTTON_BOX * 2
    )
    self._customButton = RectButton(x, y, SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX, "Custom")

    self._backButton =
        RectButton(
        WINDOW_WIDTH / 2 - BACK_BUTTON_WIDTH / 2,
        WINDOW_HEIGHT - 80,
        BACK_BUTTON_WIDTH,
        BACK_BUTTON_HEIGHT,
        "BACK"
    )
end

function BoardState:render()
    self._smallButton:render()
    self._mediumButton:render()
    self._largeButton:render()
    self._customButton:render()
    self._backButton:render()
end

function BoardState:update(dt)
    if (self._backButton:collidesWithMouse() and love.mouse.wasPressed(1)) then
        gStateMachine:change("menu")
    end
end
