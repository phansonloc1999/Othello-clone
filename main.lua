require("src/Dependencies")

function love.load()
    gBackground = {
        default = love.graphics.newImage("assets/Background.png")
    }

    gFont = love.graphics.newFont("assets/Font/font.ttf", 14)

    AudioManager.add("select", "assets/Sounds/select.ogg", "static")
    AudioManager.add("move", "assets/Sounds/move.wav", "static")
    AudioManager.add("score", "assets/Sounds/score.wav", "static")

    AudioManager.add("play", "assets/Sounds/bgm.mp3", "stream", 0.4)

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
        end,
        ["about"] = function()
            return AboutState()
        end
    }
    gStateMachine:change("menu")

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.draw()
    gStateMachine:render()
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
