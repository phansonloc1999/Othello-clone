---@class Animation
Animation = Class {}

function Animation:init(frames, intervals, positions)
    self._frames = frames
    self._currentFrame = 1
    self._intervals = intervals
    self._timer = 0
    self._positions = positions
end

function Animation:render()
    for i = 1, #self._positions do
        love.graphics.draw(self._frames[self._currentFrame], self._positions[i][1], self._positions[i][2])
    end
end

function Animation:update(dt)
    if (self._currentFrame < #self._frames) then
        if (self._timer < self._intervals[self._currentFrame]) then
            self._timer = math.min(self._intervals[self._currentFrame], self._timer + dt)
        end

        if (self._timer >= self._intervals[self._currentFrame]) then
            self._currentFrame = self._currentFrame + 1
            self._timer = 0
        end
    end
end

function Animation:reset()
    self._currentFrame = 1
    self._timer = 0
end

function Animation:setPositions(positions)
    self._positions = positions
end

function Animation:isFinished()
    if (self._currentFrame == #self._frames) then
        return true
    end
    return false
end
