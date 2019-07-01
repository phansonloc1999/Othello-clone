---@class RectButton
RectButton = Class {}

function RectButton:init(boxX, boxY, boxWidth, boxHeight, texturePaths, textString, textColor, font)
    self._boxX, self._boxY = boxX, boxY
    self._boxWidth, self._boxHeight = boxWidth, boxHeight

    if (texturePaths) then
        self._textures = {}
        for key, path in pairs(texturePaths) do
            self._textures[key] = love.graphics.newImage(path)
        end
    else
        self._textures = nil
    end

    if (textString) then
        local loveText = love.graphics.newText(font or love.graphics.getFont(), textString)
        self._text =
            Text(
            self._boxX + self._boxWidth / 2 - loveText:getWidth() / 2,
            self._boxY + self._boxHeight / 2 - loveText:getHeight() / 2,
            textString,
            font,
            textColor or {1, 1, 1}
        )
    end

    self._selected = false
end

function RectButton:render()
    if (not self._textures) then
        love.graphics.setColor(gColors.WHITE)
        love.graphics.rectangle("fill", self._boxX, self._boxY, self._boxWidth, self._boxHeight)
    else
        if (self._selected) then
            love.graphics.draw(self._textures["selected"], self._boxX, self._boxY)
        else
            love.graphics.draw(self._textures["deselected"], self._boxX, self._boxY)
        end
    end

    if (self._text) then
        self._text:render()
    end
end

function RectButton:collidesWithMouse()
    return CheckCollision(
        self._boxX,
        self._boxY,
        self._boxWidth,
        self._boxHeight,
        love.mouse.getX(),
        love.mouse.getY(),
        1,
        1
    )
end

function RectButton:select()
    self._selected = true
    self._boxX, self._boxY =
        self._boxX + math.floor((self._boxWidth - self._textures["selected"]:getWidth()) / 2),
        self._boxY + math.floor((self._boxHeight - self._textures["selected"]:getHeight()) / 2)
    self._boxWidth, self._boxHeight = self._textures["selected"]:getWidth(), self._textures["selected"]:getHeight()

    love.audio.play(gSounds.hover)
end

function RectButton:deselect()
    self._selected = false
    self._boxX, self._boxY =
        self._boxX - math.floor((self._textures["deselected"]:getWidth() - self._boxWidth) / 2),
        self._boxY - math.floor((self._textures["deselected"]:getHeight() - self._boxHeight) / 2)
    self._boxWidth, self._boxHeight = self._textures["deselected"]:getWidth(), self._textures["deselected"]:getHeight()
end
