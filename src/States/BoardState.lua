---@class BoardState
BoardState = Class {__includes = BaseState}

local SIZE_BUTTON_WIDTH, SIZE_BUTTON_BOX = 80, 80
local BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT = 100, 30

function BoardState:init()
    ---@type RectButton[]
    local buttonTexture = love.graphics.newImage("assets/SmallBoard_deselected.png")
    self._buttons = {
        ["small"] = RectButton(
            WINDOW_WIDTH / 2 - buttonTexture:getWidth() - 10,
            WINDOW_HEIGHT / 2 - buttonTexture:getHeight() - 10,
            buttonTexture:getWidth(),
            buttonTexture:getHeight(),
            {deselected = "assets/SmallBoard_deselected.png", selected = "assets/SmallBoard_selected.png"}
        )
    }

    buttonTexture = love.graphics.newImage("assets/MediumBoard_deselected.png")
    local x, y =
        getPositionsWithOffsets(
        self._buttons["small"]._boxX,
        self._buttons["small"]._boxY,
        buttonTexture:getWidth() + 10,
        0
    )
    self._buttons["medium"] =
        RectButton(
        x,
        y,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/MediumBoard_deselected.png", selected = "assets/MediumBoard_selected.png"}
    )

    buttonTexture = love.graphics.newImage("assets/BigBoard_deselected.png")
    x, y =
        getPositionsWithOffsets(
        self._buttons["small"]._boxX,
        self._buttons["small"]._boxY,
        0,
        buttonTexture:getWidth() + 10
    )
    self._buttons["big"] =
        RectButton(
        x,
        y,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/BigBoard_deselected.png", selected = "assets/BigBoard_selected.png"}
    )

    buttonTexture = love.graphics.newImage("assets/CustomBoard_deselected.png")
    x, y =
        getPositionsWithOffsets(
        self._buttons["small"]._boxX,
        self._buttons["small"]._boxY,
        buttonTexture:getWidth() + 10,
        buttonTexture:getHeight() + 10
    )
    self._buttons["custom"] =
        RectButton(
        x,
        y,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/CustomBoard_deselected.png", selected = "assets/CustomBoard_deselected.png"} --TODO: add selected texture later
    )

    buttonTexture = love.graphics.newImage("assets/Back_deselected.png")
    self._buttons["back"] =
        RectButton(
        WINDOW_WIDTH / 2 - buttonTexture:getWidth() / 2,
        WINDOW_HEIGHT - 80,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/Back_deselected.png", selected = "assets/Back_selected.png"}
    )

    self._title = love.graphics.newImage("assets/GameTitle.png")
end

function BoardState:enter(params)
    self._numOfPlayer = params.numOfPlayer
end

function BoardState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gBackground.default)

    love.graphics.draw(self._title, WINDOW_WIDTH / 2 - self._title:getWidth() / 2, 30)

    for k, v in pairs(self._buttons) do
        self._buttons[k]:render()
    end
end

function BoardState:update(dt)
    if (self._buttons["back"]:collidesWithMouse() and love.mouse.wasPressed(1)) then
        gStateMachine:change("player")
    end

    for key, button in pairs(self._buttons) do
        if (button:collidesWithMouse() and not button._selected) then
            button:select()
        end
        if (not button:collidesWithMouse() and button._selected) then
            button:deselect()
        end
    end

    local boardSizes = {"small", "medium", "big"}
    for key = 1, #boardSizes do
        if (self._buttons[boardSizes[key]]:collidesWithMouse() and love.mouse.wasPressed(1)) then
            gStateMachine:change("play", {size = boardSizes[key], numOfPlayer = self._numOfPlayer})
        end
    end
end
