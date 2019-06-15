---@class RectButton
RectButton = Class {}

function RectButton:init(boxX, boxY, boxWidth, boxHeight, texturePath, textString, textColor, font)
    self._boxX, self._boxY = boxX, boxY
    self._boxWidth, self._boxHeight = boxWidth, boxHeight

    if (texturePath) then
        self._texture = love.graphics.newImage(texturePath)
    else
        self._texture = nil
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
end

function RectButton:render()
    if (not self._texture) then
        love.graphics.setColor(gColors.WHITE)
        love.graphics.rectangle("fill", self._boxX, self._boxY, self._boxWidth, self._boxHeight)
    else
        love.graphics.draw(self._texture, self._boxX, self._boxY)
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
