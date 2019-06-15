--- Get new positions with X, Y offsets
function getPositionsWithOffsets(x, y, offsetX, offsetY)
    return x + offsetX, y + offsetY
end

--- Get the center X of parent width
function getCenterX(parentX, parentWidth, objectWidth)
    return parentX + parentWidth / 2 - objectWidth / 2
end

--- Get the center Y of parent height
function getCenterY(parentY, parentHeight, objectHeight)
    return parentY + parentHeight / 2 - objectHeight / 2
end
