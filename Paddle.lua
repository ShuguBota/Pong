Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.speed = 0
end

function Paddle:update(dt)
    if self.speed <= 0 then
        self.y = math.max(self.y + self.speed * dt, 0)
    else
        self.y = math.min(self.y + self.speed * dt, VIRTUAL_HEIGHT - self.height)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end