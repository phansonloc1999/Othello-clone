---@class Text
Text = Class {}

function Text:init(x, y, textString, font, color)
    self._x, self._y = x or 0, y or 0
    self._text = love.graphics.newText(font or love.graphics.getFont(), textString)
    self._width, self._height = self._text:getWidth(), self._text:getHeight()
    self._color = color or gColors.WHITE
end

function Text:render()
    love.graphics.setColor(self._color)
    love.graphics.draw(self._text, self._x, self._y)
    love.graphics.setColor(gColors.WHITE)
end

function Text:setPos(newX, newY)
    self._x, self._y = newX, newY
end

function Text:getWidth()
    return self._width
end

function Text:getHeight()
    return self._height
end
