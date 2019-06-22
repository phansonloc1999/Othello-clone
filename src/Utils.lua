--- AABB Collision
function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

--- Single mouse input
love.mouse.buttonsPressed = {}

function love.mousepressed(x, y, button, istouch)
    love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

--- Single keyboard input
love.keyboard.keysPressed = {}

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function belongsTo(parentTable, subTable)
    for i = 1, #parentTable do
        for j = 1, #parentTable[i] do
            if (parentTable[i][j] ~= subTable[j]) then
                break
            end
            if (j == 2) then
                return true
            end
        end
    end
    return false
end
