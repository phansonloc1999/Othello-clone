---@class BoardState
BoardState = Class {__includes = BaseState}

local SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX = 80, 80
local BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT = 100, 30

function BoardState:init()
    ---@type RectButton[]
    self._buttons = {
        ["small"] = RectButton(
            WINDOW_WIDTH / 2 - 3 * SIZE_BUTTON_WIDTH / 2,
            WINDOW_HEIGHT / 2 - 3 * SIZE_BUTTON_BOX / 2,
            SIZE_BUTTON_WIDTH,
            SIZE_BUTTON_BOX,
            nil,
            "Small",
            gColors.BLACK
        )
    }

    local x, y =
        getPositionsWithOffsets(self._buttons["small"]._boxX, self._buttons["small"]._boxY, SIZE_BUTTON_WIDTH * 2, 0)
    self._buttons["medium"] = RectButton(x, y, SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX, nil, "Medium", gColors.BLACK)

    x, y = getPositionsWithOffsets(self._buttons["small"]._boxX, self._buttons["small"]._boxY, 0, SIZE_BUTTON_BOX * 2)
    self._buttons["large"] = RectButton(x, y, SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX, nil, "Large", gColors.BLACK)

    x, y =
        getPositionsWithOffsets(
        self._buttons["small"]._boxX,
        self._buttons["small"]._boxY,
        SIZE_BUTTON_WIDTH * 2,
        SIZE_BUTTON_BOX * 2
    )
    self._buttons["custom"] = RectButton(x, y, SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX, nil, "Custom", gColors.BLACK)

    self._buttons["back"] =
        RectButton(
        WINDOW_WIDTH / 2 - BACK_BUTTON_WIDTH / 2,
        WINDOW_HEIGHT - 80,
        BACK_BUTTON_WIDTH,
        BACK_BUTTON_HEIGHT,
        nil,
        "BACK",
        gColors.BLACK
    )
end

function BoardState:enter(params)
    self._numOfPlayer = params.numOfPlayer
end

function BoardState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gBackground.default)

    for k, v in pairs(self._buttons) do
        self._buttons[k]:render()
    end
end

function BoardState:update(dt)
    if (self._buttons["back"]:collidesWithMouse() and love.mouse.wasPressed(1)) then
        gStateMachine:change("player")
    end

    local boardSizes = {"small", "medium", "large"}
    for key = 1, #boardSizes do
        if (self._buttons[boardSizes[key]]:collidesWithMouse() and love.mouse.wasPressed(1)) then
            gStateMachine:change("play", {size = boardSizes[key], numOfPlayer = self._numOfPlayer})
        end
    end
end
