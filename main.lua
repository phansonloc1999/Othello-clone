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
        ["player"] = function()
            return PlayerState()
        end,
        ["play"] = function()
            return PlayState()
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

    gFont = love.graphics.newFont("assets/Font/font.ttf", 14)

    gSounds = {
        select = love.audio.newSource("assets/Sounds/select.ogg", "static"),
        move = love.audio.newSource("assets/Sounds/move.wav", "static")
    }

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.draw()
    gStateMachine:render()

    love.graphics.setColor(1, 0, 0)
end

function love.update(dt)
    if dt < 1 / 30 then
        love.timer.sleep(1 / 30 - dt)
    end

    gStateMachine:update(dt)

    -- Reset mouse input table every frames
    love.mouse.buttonsPressed = {}
    love.keyboard.keysPressed = {}
end
