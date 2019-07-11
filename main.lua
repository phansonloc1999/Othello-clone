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

    gSettings = {}
    local texture = love.graphics.newImage("assets/Settings UI/Music_on.png")
    gSettings.music = {
        textures = {
            on = texture,
            off = love.graphics.newImage("assets/Settings UI/Music_off.png")
        },
        x = 0,
        y = WINDOW_HEIGHT - texture:getHeight(),
        width = texture:getWidth(),
        height = texture:getHeight(),
        state = "on"
    }
    texture = love.graphics.newImage("assets/Settings UI/Sound_on.png")
    gSettings.sound = {
        textures = {
            on = texture,
            off = love.graphics.newImage("assets/Settings UI/Sound_off.png")
        },
        x = gSettings.music.x + texture:getWidth() + 2,
        y = gSettings.music.y,
        width = texture:getWidth(),
        height = texture:getHeight(),
        state = "on"
    }
end

function love.draw()
    gStateMachine:render()

    for key, setting in pairs(gSettings) do
        if (setting.state == "on") then
            love.graphics.draw(setting.textures["on"], setting.x, setting.y)
        else
            love.graphics.draw(setting.textures["off"], setting.x, setting.y)
        end
    end
end

function love.update(dt)
    if dt < 1 / 30 then
        love.timer.sleep(1 / 30 - dt)
    end

    if (love.mouse.wasPressed(1)) then
        if
            (CheckCollision(
                gSettings.music.x,
                gSettings.music.y,
                gSettings.music.width,
                gSettings.music.height,
                love.mouse.getX(),
                love.mouse.getY(),
                1,
                1
            ))
         then
            if (gSettings.music.state == "on") then
                gSettings.music.state = "off"
                AudioManager.muteMusic()
            else
                gSettings.music.state = "on"
                AudioManager.unmuteMusic()
            end
            AudioManager._musicMuted = not AudioManager._musicMuted
        end

        if
            (CheckCollision(
                gSettings.sound.x,
                gSettings.sound.y,
                gSettings.sound.width,
                gSettings.sound.height,
                love.mouse.getX(),
                love.mouse.getY(),
                1,
                1
            ))
         then
            if (gSettings.sound.state == "on") then
                gSettings.sound.state = "off"
                AudioManager.muteSound()
            else
                gSettings.sound.state = "on"
                AudioManager.unmuteSound()
            end
            AudioManager._soundMuted = not AudioManager._soundMuted
        end
    end

    gStateMachine:update(dt)

    -- Reset mouse input table every frames
    love.mouse.buttonsPressed = {}
    love.keyboard.keysPressed = {}
end
