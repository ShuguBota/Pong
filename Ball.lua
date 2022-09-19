Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    --Velocity
    self.dx = 150
    self.dy = math.random(-50, 50)
end

function Ball:reset(playerToServe)
    self.x = VIRTUAL_WIDTH/2 - 2
    self.y = VIRTUAL_HEIGHT/2 - 2
    if playerToServe == 1 then
        self.dx = 150
    else
        self.dx = -150
    end
    self.dy = math.random(-50, 50) * 1.5
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:collide(paddle)
    if self.x <= paddle.x + paddle.width and
       self.x + self.width >= paddle.x and
       self.y <= paddle.y + paddle.height and
       self.y + self.height >= paddle.y then
        return true
    else
        return false
    end
end