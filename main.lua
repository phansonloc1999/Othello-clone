require("src/Dependencies")

function love.load()
    gStateMachine =
        StateMachine {
        ["menu"] = function()
            return MenuState()
        end,
        ["play"] = function()
            return BoardState()
        end
    }
    gStateMachine:change("menu")
end

function love.draw()
    gStateMachine:render()
end

function love.update(dt)
    gStateMachine:update(dt)

    -- Reset mouse input table every frames
    love.mouse.buttonsPressed = {}
end
