---@class Text
Text = Class {}

function Text:init(x, y, textString, font, color)
    self._x, self._y = x, y
    self._text = love.graphics.newText(font or love.graphics.getFont(), textString)
    self._width = self._text:getWidth(), self._text:getHeight()
    self._color = color or gColors.WHITE
end

function Text:render()
    love.graphics.draw(self._text, self._x, self._y)
end

function Text:setPos(newX, newY)
    self._x, self._y = newX, newY
end
