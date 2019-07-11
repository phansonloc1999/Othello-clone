---@class AboutState
AboutState = Class {__includes = BaseState}

function AboutState:init()
    self._textures = {
        love.graphics.newImage("assets/Guides/First.png"),
        love.graphics.newImage("assets/Guides/HTL1.png"),
        love.graphics.newImage("assets/Guides/HTL2.png"),
        love.graphics.newImage("assets/Guides/HTL3.png"),
        love.graphics.newImage("assets/Guides/HTL4.png"),
        love.graphics.newImage("assets/Guides/HTL5.png"),
        love.graphics.newImage("assets/Guides/End.png")
    }
    self._pageNumber = 1

    self._text = Text(0, 0, self._pageNumber .. " / 7", gFont, gColors.BLACK)
    self._text:setPos(getCenterX(0, WINDOW_WIDTH, self._text:getWidth()), WINDOW_HEIGHT - 70)

    self._buttons = {} ---@type RectButton[]
    local texture = love.graphics.newImage("assets/Guides/Button/Ok_deselected.png")
    self._buttons["ok"] =
        RectButton(
        WINDOW_WIDTH / 2 - texture:getWidth() / 2,
        self._text._y + 20,
        texture:getWidth(),
        texture:getHeight(),
        {deselected = "assets/Guides/Button/Ok_deselected.png", selected = "assets/Guides/Button/Ok_selected.png"}
    )

    texture = love.graphics.newImage("assets/Guides/Button/Next_deselected.png")
    self._buttons["next"] =
        RectButton(
        self._buttons.ok._boxX - texture:getWidth() - 12,
        self._buttons.ok._boxY,
        texture:getWidth(),
        texture:getHeight(),
        {
            deselected = "assets/Guides/Button/Next_deselected.png",
            selected = "assets/Guides/Button/Next_selected.png"
        }
    )

    texture = love.graphics.newImage("assets/Guides/Button/Previous_deselected.png")
    self._buttons["previous"] =
        RectButton(
        self._buttons.ok._boxX + self._buttons.ok._boxWidth + 12,
        self._buttons.ok._boxY,
        texture:getWidth(),
        texture:getHeight(),
        {
            deselected = "assets/Guides/Button/Previous_deselected.png",
            selected = "assets/Guides/Button/Previous_selected.png"
        }
    )
end

function AboutState:render()
    love.graphics.draw(self._textures[self._pageNumber])
    self._text:render()

    for key, button in pairs(self._buttons) do
        button:render()
    end
end

function AboutState:update(dt)
    for key, button in pairs(self._buttons) do
        if (button:collidesWithMouse() and not button._selected) then
            button:select()
        end
        if (button._selected and not button:collidesWithMouse()) then
            button:deselect()
        end
    end

    if (love.mouse.wasPressed(1)) then
        if (self._buttons.ok:collidesWithMouse()) then
            gStateMachine:change("menu")
            AudioManager.play("select")
        end
        if (self._buttons.next:collidesWithMouse()) then
            self._pageNumber = self._pageNumber > 1 and self._pageNumber - 1 or 7
            self._text = Text(0, 0, self._pageNumber .. " / 7", gFont, gColors.BLACK)
            self._text:setPos(getCenterX(0, WINDOW_WIDTH, self._text:getWidth()), WINDOW_HEIGHT - 70)
            AudioManager.play("select")
        elseif (self._buttons.previous:collidesWithMouse()) then
            self._pageNumber = self._pageNumber < 7 and self._pageNumber + 1 or 1
            self._text = Text(0, 0, self._pageNumber .. " / 7", gFont, gColors.BLACK)
            self._text:setPos(getCenterX(0, WINDOW_WIDTH, self._text:getWidth()), WINDOW_HEIGHT - 70)
            AudioManager.play("select")
        end
    end
end
