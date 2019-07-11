---@class PlayerState
PlayerState = Class {__includes = BaseState}

function PlayerState:init()
    self._buttons = {}

    local ButtonTexture = love.graphics.newImage("assets/1Player_deselected.png")
    self._buttons._1PlayerButton =
        RectButton(
        getCenterX(0, WINDOW_WIDTH / 2, ButtonTexture:getWidth()),
        WINDOW_HEIGHT / 4,
        ButtonTexture:getWidth(),
        ButtonTexture:getHeight(),
        {deselected = "assets/1Player_deselected.png", selected = "assets/1Player_selected.png"}
    )

    ButtonTexture = love.graphics.newImage("assets/2Player_deselected.png")
    self._buttons._2PlayerButton =
        RectButton(
        getCenterX(WINDOW_WIDTH / 2, WINDOW_WIDTH / 2, ButtonTexture:getWidth()),
        WINDOW_HEIGHT / 4,
        ButtonTexture:getWidth(),
        ButtonTexture:getHeight(),
        {deselected = "assets/2Player_deselected.png", selected = "assets/2Player_selected.png"}
    )

    ButtonTexture = love.graphics.newImage("assets/Back_deselected.png")
    self._buttons._backButton =
        RectButton(
        getCenterX(0, WINDOW_WIDTH, ButtonTexture:getWidth()),
        WINDOW_HEIGHT - 120,
        ButtonTexture:getWidth(),
        ButtonTexture:getHeight(),
        {deselected = "assets/Back_deselected.png", selected = "assets/Back_selected.png"}
    )
end

function PlayerState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gBackground.default)

    for key, button in pairs(self._buttons) do
        button:render()
    end
end

function PlayerState:update(dt)
    for key, button in pairs(self._buttons) do
        if (button:collidesWithMouse() and button._selected == false) then
            button:select()
        end
        if (not button:collidesWithMouse() and button._selected == true) then
            button:deselect()
        end
    end

    if (love.mouse.wasPressed(1)) then
        if (self._buttons._1PlayerButton:collidesWithMouse()) then
            AudioManager.play("select")
            gStateMachine:change("board", {numOfPlayer = 1})
        end
        if (self._buttons._2PlayerButton:collidesWithMouse()) then
            AudioManager.play("select")
            gStateMachine:change("board", {numOfPlayer = 2})
        end
        if (self._buttons._backButton:collidesWithMouse()) then
            AudioManager.play("select")
            gStateMachine:change("menu")
        end
    end
end
