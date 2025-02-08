local bullets = {
    bullets = {},
    bulletImage = nil,
    bulletSpeed = 500,
    type = {
        spiral = 1,
        straight = 2,
        homing = 3
    }
}

function bullets:load()
    world:addCollisionClass("Bullet")
    self.bulletImage = love.graphics.newImage("assets/bullet.png")
    for i = 1, 20 do
        table.insert(self.bullets, self:createBullet(i, self.type.spiral, 400 + i * 50, 300 + i * 50, 0, 0))
    end
end

function bullets:createBullet(index, type, x, y, dx, dy)
    local bullet = {
        image = self.bulletImage,
        speed = self.bulletSpeed,
        collider = world:newCircleCollider(x, y, 10),
        index = index,
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        type = type
    }
    bullet.collider:setCollisionClass("Bullet")
    bullet.collider:setType("static")
    return bullet
end

function bullets:reset()
    for i, v in ipairs(self.bullets) do
        v.x, v.y, v.dx, v.dy = 0, 0, 0, 0
    end
end

function bullets:changeType()
    local newType = math.random(1, 3)
    for _, v in ipairs(self.bullets) do
        v.type = 3
    end
end

function bullets:update(dt)
    window_width, window_height = love.graphics.getDimensions()  -- Get screen size

    for _, v in ipairs(self.bullets) do
        -- If the bullet has no direction assigned, give it a random one
        if not v.dx or not v.dy then
            local angle = love.math.random() * (2 * math.pi) -- Random angle (0 to 360 degrees)
            v.dx = math.cos(angle) * v.speed
            v.dy = math.sin(angle) * v.speed
        end

        -- Update position
        v.x = v.x + v.dx * dt
        v.y = v.y + v.dy * dt

        -- Bounce off edges
        if v.x <= 0 or v.x >= window_width then
            v.dx = -v.dx -- Reverse X direction
            v.x = math.max(0, math.min(v.x, window_width)) -- Keep within bounds
        end
        if v.y <= 0 or v.y >= window_height then
            v.dy = -v.dy -- Reverse Y direction
            v.y = math.max(0, math.min(v.y, window_height)) -- Keep within bounds
        end

        v.collider:setPosition(v.x, v.y)
    end
end



function bullets:draw()
    for _, v in ipairs(self.bullets) do
        love.graphics.draw(self.bulletImage, v.collider:getX(), v.collider:getY(), 0, 1, 1, self.bulletImage:getWidth()/2, self.bulletImage:getHeight()/2)
        world:draw()
    end
end

return bullets
