---@class MenuState
MenuState = Class {__includes = BaseState}

LARGE_DEFAULT_FONT = love.graphics.newFont(35)
DEFAULT_FONT = love.graphics.setNewFont(12)

function MenuState:init()
    self._buttons = {}
    self._buttons.startButton =
        RectButton(
        getCenterX(0, love.graphics.getWidth(), 120),
        getCenterY(0, love.graphics.getHeight(), 30) + 50,
        120,
        40,
        {deselected = "assets/Start_deselected.png", selected = "assets/Start_selected.png"},
        nil,
        gColors.BLACK
    )

    local aboutButtonX, aboutButtonY =
        getPositionsWithOffsets(self._buttons.startButton._boxX, self._buttons.startButton._boxY, 0, 60)
    self._buttons.aboutButton =
        RectButton(
        aboutButtonX,
        aboutButtonY,
        self._buttons.startButton._boxWidth,
        self._buttons.startButton._boxHeight,
        {deselected = "assets/About_deselected.png", selected = "assets/About_selected.png"},
        nil,
        gColors.BLACK
    )

    local quitButtonX, quitButtonY =
        getPositionsWithOffsets(self._buttons.aboutButton._boxX, self._buttons.aboutButton._boxY, 0, 60)
    self._buttons.quitButton =
        RectButton(
        quitButtonX,
        quitButtonY,
        self._buttons.aboutButton._boxWidth,
        self._buttons.aboutButton._boxHeight,
        {deselected = "assets/Quit_deselected.png", selected = "assets/Quit_selected.png"},
        nil,
        gColors.BLACK
    )

    self._gameTitle = {
        selected = love.graphics.newImage("assets/Title.png"),
        y = 25
    }
    self._gameTitle.x = love.graphics.getWidth() / 2 - self._gameTitle.selected:getWidth() / 2
end

function MenuState:render()
    for key, button in pairs(self._buttons) do
        button:render()
    end
    love.graphics.draw(self._gameTitle.selected, self._gameTitle.x, self._gameTitle.y)
end

function MenuState:update(dt)
    if (love.mouse.wasPressed(1)) then
        if (self._buttons.quitButton:collidesWithMouse()) then
            love.event.quit()
        end
        if (self._buttons.startButton:collidesWithMouse()) then
            gStateMachine:change("board")
        end
    end

    for key, button in pairs(self._buttons) do
        if (button:collidesWithMouse() and button._selected == false) then
            button:select()
        end
        if (not button:collidesWithMouse() and button._selected == true) then
            button:deselect()
        end
    end
end
