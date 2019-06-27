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

    love.graphics.setColor(1, 0, 0)
    love.graphics.print(love.timer.getFPS())
end

function love.update(dt)
    if dt < 1 / 30 then
        love.timer.sleep(1 / 30 - dt)
    end

    gStateMachine:update(dt)

    -- Reset mouse input table every frames
    love.mouse.buttonsPressed = {}
    love.keyboard.keysPressed = {}

    require("lib/lovebird").update()
end
