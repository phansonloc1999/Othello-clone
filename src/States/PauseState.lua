---@class PauseState
PauseState = Class {__includes = BaseState}

function PauseState:init()
    ---@type RectButton[]
    self._buttons = {}

    local buttonTexture = love.graphics.newImage("assets/Back_deselected.png")
    self._buttons["back"] =
        RectButton(
        WINDOW_WIDTH / 2 - buttonTexture:getWidth() / 2,
        WINDOW_HEIGHT / 3 + 20,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/Back_deselected.png", selected = "assets/Back_selected.png"}
    )

    buttonTexture = love.graphics.newImage("assets/Reset_deselected.png")
    local tempX, tempY = getPositionsWithOffsets(self._buttons["back"]._boxX, self._buttons["back"]._boxY, 0, 80)
    self._buttons["reset"] =
        RectButton(
        tempX,
        tempY,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/Reset_deselected.png", selected = "assets/Reset_selected.png"}
    )

    buttonTexture = love.graphics.newImage("assets/Menu_deselected.png")
    local tempX, tempY = getPositionsWithOffsets(self._buttons["reset"]._boxX, self._buttons["reset"]._boxY, 0, 80)
    self._buttons["menu"] =
        RectButton(
        tempX,
        tempY,
        buttonTexture:getWidth(),
        buttonTexture:getHeight(),
        {deselected = "assets/Menu_deselected.png", selected = "assets/Menu_selected.png"}
    )

    self._gameTitle = love.graphics.newImage("assets/GameTitle.png")
end

function PauseState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gBackground.default)

    love.graphics.draw(self._gameTitle, WINDOW_WIDTH / 2 - self._gameTitle:getWidth() / 2, 50)

    for key, button in pairs(self._buttons) do
        button:render()
    end
end

function PauseState:update(dt)
    for key, button in pairs(self._buttons) do
        if button:collidesWithMouse() and not button._selected then
            button:select()
        end
        if not button:collidesWithMouse() and button._selected then
            button:deselect()
        end
    end

    if (love.mouse.wasPressed(1)) then
        if (self._buttons["back"]:collidesWithMouse()) then
            AudioManager.play("select")
            gStateMachine:change(
                "play",
                {
                    pausedPlayState = self._pausedPlayState,
                    size = self._pausedPlayState._size,
                    numOfPlayer = self._pausedPlayState._numOfPlayer
                }
            )
        end
        if (self._buttons["reset"]:collidesWithMouse()) then
            AudioManager.stop("play")
            AudioManager.play("select")
            gStateMachine:change(
                "play",
                {size = self._pausedPlayState._size, numOfPlayer = self._pausedPlayState._numOfPlayer}
            )
        end
        if (self._buttons["menu"]:collidesWithMouse()) then
            AudioManager.play("select")
            gStateMachine:change("menu")
        end
    end
end

function PauseState:enter(params)
    AudioManager.pause("play")
    self._pausedPlayState = params.pausedPlayState
end

function PauseState:exit()
    AudioManager.play("play")
end