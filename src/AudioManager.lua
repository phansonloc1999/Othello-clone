AudioManager = {}

AudioManager._sounds = {}
AudioManager._musics = {}
AudioManager._soundMuted, AudioManager._musicMuted = false, false

function AudioManager.add(key, audioPath, type, volume)
    assert(type, "static or stream must be specified!")
    if (type == "static") then
        AudioManager._sounds[key] = love.audio.newSource(audioPath, type)
        AudioManager._sounds[key]:setVolume(volume or 1)
    else
        AudioManager._musics[key] = love.audio.newSource(audioPath, type)
        AudioManager._musics[key]:setLooping(true)
        AudioManager._musics[key]:setVolume(volume or 1)
    end
end

function AudioManager.play(targetKey)
    for key, audio in pairs(AudioManager._sounds) do
        if (key == targetKey) then
            audio:play()
        end
    end
    for key, audio in pairs(AudioManager._musics) do
        if (key == targetKey) then
            audio:play()
        end
    end
end

function AudioManager.pause(targetKey)
    for key, audio in pairs(AudioManager._sounds) do
        if (key == targetKey) then
            audio:pause()
            return 0
        end
    end
    for key, audio in pairs(AudioManager._musics) do
        if (key == targetKey) then
            audio:pause()
            return 0
        end
    end
    assert(nil, "Target audio not found!")
end

function AudioManager.stop(targetKey)
    for key, audio in pairs(AudioManager._sounds) do
        if (key == targetKey) then
            audio:stop()
            return 0
        end
    end
    for key, audio in pairs(AudioManager._musics) do
        if (key == targetKey) then
            audio:stop()
            return 0
        end
    end
    assert(nil, "Target audio not found!")
end

function AudioManager.muteMusic()
    AudioManager._musicMuted = true
    for key, audio in pairs(AudioManager._musics) do
        audio:setVolume(0)
    end
end

function AudioManager.muteSound()
    AudioManager._soundMuted = true
    for key, audio in pairs(AudioManager._sounds) do
        audio:setVolume(0)
    end
end

function AudioManager.unmuteMusic()
    AudioManager._musicMuted = false
    for key, audio in pairs(AudioManager._musics) do
        audio:setVolume(0.4)
    end
end

function AudioManager.unmuteSound()
    AudioManager._soundMuted = false
    for key, audio in pairs(AudioManager._sounds) do
        audio:setVolume(1)
    end
end
