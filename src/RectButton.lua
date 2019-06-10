---@class RectButton
RectButton = Class {}

function RectButton:init(boxX, boxY, boxWidth, boxHeight, textString, textColor, font)
    self._boxX, self._boxY = boxX, boxY
    self._boxWidth, self._boxHeight = boxWidth, boxHeight
    self._text = love.graphics.newText(font or love.graphics.getFont(), textString)
    self._textColor = textColor or {1, 1, 1}
end

function RectButton:render()
    love.graphics.rectangle("line", self._boxX, self._boxY, self._boxWidth, self._boxHeight)

    love.graphics.setColor(self._textColor)
    love.graphics.draw(
        self._text,
        self._boxX + self._boxWidth / 2 - self._text:getWidth() / 2,
        self._boxY + self._boxHeight / 2 - self._text:getHeight() / 2
    )
    love.graphics.setColor(1, 1, 1)
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
