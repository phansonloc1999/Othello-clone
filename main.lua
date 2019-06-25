require("src/Dependencies")

function love.load()
    gStateMachine =
        StateMachine {
        ["menu"] = function()
            return MenuState()
        end,
        ["board"] = function()
            return BoardState()
        end,
        ["play"] = function()
            return PlayState()
        end,
        ["player"] = function()
            return PlayerState()
        end,
        ["pause"] = function()
            return PauseState()
        end,
        ["score"] = function()
            return ScoreState()
        end
    }
    gStateMachine:change("menu")

    gBackground = {
        default = love.graphics.newImage("assets/Background.png")
    }

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.draw()
    gStateMachine:render()
end

function love.update(dt)
    gStateMachine:update(dt)

    -- Reset mouse input table every frames
    love.mouse.buttonsPressed = {}
    love.keyboard.keysPressed = {}

    require("lib/lovebird").update()
end
