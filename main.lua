local LoveDialogue = require "LoveDialogue"
--local DebugConsole = require "Debuging.DebugConsole"

local myDialogue
local bossIntro
local countdown = 300
local countSheep = 0
local isMovingTowardPlayer = false
local direction_x, direction_y 
local spread = 300
local invisframe = 0
local restart = false
local colliderIsHere = true

Sheep = {}
Sheep.__index = Sheep

function Sheep:new(x, y)
    local self = setmetatable({}, Sheep)
    self.x = x
    self.y = y
    self.speed = 100
    self.spriteSheet = love.graphics.newImage("Assets/sprites/sheep.png")
    self.grid = anim8.newGrid(128, 128, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations["idle"] = anim8.newAnimation(self.grid('1-6', 1), 0.2)
    self.anim = self.animations["idle"]
    self.collider = world:newBSGRectangleCollider(x, y, 32, 32, 14)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass("Sheep")
    return self
end

function Sheep:update(dt)
    self.anim:update(dt)
    self.x = self.collider:getX()
    self.y = self.collider:getY()
end

function Sheep:draw()
    self.anim:draw(self.spriteSheet, self.x - 64, self.y - 64)
end

myDialogue = LoveDialogue.play("dialogue.ld", {
        boxHeight = 150,
        portraitEnabled = true
})
myDialogue.isActive = false


bossIntro = LoveDialogue.play("dialogue2.ld", {
        boxHeight = 150,
        portraitEnabled = true
    })
bossIntro.isActive = false


function love.load()
    anim8 = require "Animation/anim8"
    wf = require 'windfield' -- a physics library for love2d
    sti = require "sti" -- a Tiled map loader for love2d
    camera = require "camera" -- a camera library for love2d
    cam = camera()

    sounds = {}
    sounds.sheep = love.audio.newSource("sound/sheep.mp3", "static")
    sounds.sheep:setVolume(0.5)
    sounds.sheep:setLooping(false)
    sounds.sheep:setPitch(1.5)

    sounds.hurt = love.audio.newSource("sound/hurt.mp3", "static")
    sounds.hurt:setVolume(0.7)
    sounds.hurt:setLooping(false)

    sounds.boss = love.audio.newSource("sound/boss.mp3", "stream")
    sounds.boss:setVolume(0.4)
    sounds.boss:setLooping(true)
    sounds.boss:setPitch(1.5)

    sounds.win = love.audio.newSource("sound/win.mp3", "static")
    sounds.win:setVolume(0.5)
    sounds.win:setLooping(true)


    sounds.start = love.audio.newSource("sound/start.mp3", "static")
    sounds.start:setVolume(0.5)
    sounds.start:setLooping(true)

    love.audio.stop()

    sounds.start:play()


    scene1 = true
    scene2 = false
    talk = true
    tele = true
    timer = 0

    gameMap = sti("Assets/maps/testmap.lua")

    -- Create a new Canvas to draw to
    canvas = love.graphics.newCanvas(1410, 2230)

    -- Create a world with standard gravity
    world = wf.newWorld(0, 0)
    world:addCollisionClass("Player")
    world:addCollisionClass("NPC")
    world:addCollisionClass("Sheep")
    world:addCollisionClass("Boss")

    -- for scaling pixel art
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- player character
    player = {}
    player.collider = world:newBSGRectangleCollider(1410, 2230, 40, 40, 14)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player")
    player.x = 1410
    player.y = 2230 -- center of scene
    player.speed = 400
    player.spriteSheet = love.graphics.newImage("Assets/sprites/Char_002.png")
    player.grid = anim8.newGrid(48, 48, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations["down"] = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations["left"] = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations["right"] = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations["up"] = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.anim = player.animations["down"]
    player.sheepCollected = 0
    -- missions
    player.captureSheep = false
    player.alive = true
    player.heath = {1, 2, 3}
    player.heathSprite = love.graphics.newImage("Assets/sprites/heart.png")

    --- npc 1450.1752929688 1093
    npc = {}
    npc.collider = world:newBSGRectangleCollider(1450, 1093, 40, 40, 14)
    npc.collider:setFixedRotation(true)
    npc.collider:setType("kinematic") -- collision detection but no physics-based movement
    npc.collider:setCollisionClass("NPC")
    npc.x = 1450
    npc.y = 1093 -- center of scene
    npc.spriteSheet = love.graphics.newImage("Assets/sprites/Pawn_Yellow.png")
    npc.grid = anim8.newGrid(192, 192, npc.spriteSheet:getWidth(), npc.spriteSheet:getHeight())
    npc.animations = {}
    npc.animations["idle"] = anim8.newAnimation(npc.grid('1-6', 1), 0.2)
    
    
    SheepList = {}  -- Store all sheep objects properly
    local startX, startY = 1620, 1323 -- Change this to adjust spawn location
    local spread = 300
    for i = 1, 25 do
        local offsetX = math.random(-spread, spread) -- Randomize x position
        local offsetY = math.random(-spread, spread) -- Randomize y position
        local sheep = Sheep:new(startX + offsetX, startY + offsetY)
        if sheep then
            table.insert(SheepList, sheep)
        end
    end

    local sandX, sandY = 1350, 1780
    local spread = 200
    for i = 1, 10 do
        local offsetX = math.random(-spread, spread) -- Randomize x position
        local offsetY = math.random(-spread, spread) -- Randomize y position
        local sheep = Sheep:new(sandX + offsetX, sandY + offsetY)
        if sheep then
            table.insert(SheepList, sheep)
        end
    end

    local cliftX, cliftY = 2165, 2015
    local spread = 250
    for i = 1, 20 do
        local offsetX = math.random(-spread, spread) -- Randomize x position
        local offsetY = math.random(-spread, spread) -- Randomize y position
        local sheep = Sheep:new(cliftX + offsetX, cliftY + offsetY)
        if sheep then
            table.insert(SheepList, sheep)
        end
    end

    -- boss character
    boss = {}
    boss.x = 200
    boss.y = 200
    boss.speed = 1200
    boss.collider = world:newBSGRectangleCollider(200, 200, 100, 100, 90)
    boss.collider:setCollisionClass("Boss")
    boss.speed = 1200
    boss.spriteSheet = love.graphics.newImage("Assets/sprites/boss.png")
    boss.draw = function()
        love.graphics.draw(
            boss.spriteSheet, 
            boss.collider:getX(), 
            boss.collider:getY(), 
            boss.collider:getAngle(), 
            1, 1,  -- Scale
            96, 96 -- Offset (half of 192x192 sprite size for proper rotation)
        )
    end

    -- bullets:load()



    function boss:draw()
        love.graphics.draw(
            boss.spriteSheet, 
            boss.collider:getX(), 
            boss.collider:getY(), 
            boss.collider:getAngle(), 
            1, 1,  -- Scale
            96, 96 -- Offset (half of 192x192 sprite size for proper rotation)
        )
    end

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(walls, wall)
        end
    end
    
end


function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

    if myDialogue.isActive then
        myDialogue:update(dt)
        return
    end

    if bossIntro.isActive then
        bossIntro:update(dt)
        return
    end

    if player.collider:enter("NPC") then
        myDialogue.isActive = true
        player.captureSheep = true
        npc.collider:destroy()
    end


    shouldBeDead = #player.heath == 0
    player.alive = not shouldBeDead

    if player.collider:enter("Boss") and invisframe <= 0 then
        invisframe = 100
        if player.alive then
            sounds.hurt:play()
            table.remove(player.heath)
        end
    end

    invisframe = invisframe - 1

    if player.sheepCollected >= 30 and talk then
        bossIntro.isActive = true
        sounds.start:stop()
        sounds.boss:play()
        talk = false
    end

    if player.captureSheep then
        if player.collider:enter("Sheep") then
            local collision_data = player.collider:getEnterCollisionData("Sheep")
            local sheep_collider = collision_data.collider
            sounds.sheep:play()
            -- search through sheepList to find the sheep object and remove it
            for i, sheep in ipairs(SheepList) do
                if sheep.collider == sheep_collider then
                    table.remove(SheepList, i)
                    break
                end
            end
            sheep_collider:destroy()
            player.sheepCollected = player.sheepCollected + 1
        end
    end

    -- move player
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        vx = player.speed 
        player.anim = player.animations["right"]
        isMoving = true
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        vx = player.speed * -1
        player.anim = player.animations["left"]
        isMoving = true
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        vy = player.speed 
        player.anim = player.animations["down"]
        isMoving = true
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        vy = player.speed * -1
        player.anim = player.animations["up"]
        isMoving = true
    end
    if not isMoving then
        player.anim:gotoFrame(2)
    end

    -- update player animation
    player.anim:update(dt)
    npc.animations["idle"]:update(dt)
    -- update sheep_collider
    for _, sheep in ipairs(SheepList) do
        sheep:update(dt)
    end
    world:update(dt)

    -- Clamp player collider position to stay within screen bounds
    if scene2 then
        player.speed = 800
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        local px, py = player.collider:getPosition()
        px = math.max(24, math.min(px, screenWidth - 24))
        py = math.max(24, math.min(py, screenHeight - 24))
        player.collider:setPosition(px, py)
    
        -- Boss movement
        local bx, by = boss.collider:getPosition()
        local bdx, bdy = boss.collider:getLinearVelocity()
        if isMovingTowardPlayer then
            -- Calculate direction once
            if direction_x == nil or direction_y == nil then
                local player_x, player_y = player.collider:getPosition()
                direction_x = player_x - bx
                direction_y = player_y - by
                local length = math.sqrt(direction_x^2 + direction_y^2)
    
                -- Normalize the direction to get a unit vector
                direction_x = direction_x / length
                direction_y = direction_y / length
            end
    
            local moveSpeed = boss.speed  -- Use the boss's speed for movement
            bdx = direction_x * moveSpeed
            bdy = direction_y * moveSpeed

            -- spawn a sheep randomly every 5 seconds
            countSheep = countSheep + 1
            if countSheep % 100 == 0 then
                local offsetX = math.random(-spread, spread) -- Randomize x position
                local offsetY = math.random(-spread, spread) -- Randomize y position
                local sheep = Sheep:new(bx + offsetX, by + offsetY)
                if sheep then
                    table.insert(SheepList, sheep)
                end
            end
        end
    
        if countdown > 0 then
            countdown = countdown - 1
        else
            local centerX, centerY = screenWidth / 2, screenHeight / 2
            local angleToCenter = math.atan2(centerY - by, centerX - bx)
            local moveSpeed = boss.speed 
            bdx = math.cos(angleToCenter) * moveSpeed
            bdy = math.sin(angleToCenter) * moveSpeed
    
            if math.abs(bx - centerX) < 5 and math.abs(by - centerY) < 5 then
                countdown = 75  -- Reset countdown timer
                isMovingTowardPlayer = true 
                direction_x, direction_y = nil, nil

            end
        end
    
        -- Boss position and velocity updates
        boss.collider:setLinearVelocity(bdx, bdy)
        boss.collider:setPosition(math.max(64, math.min(bx, screenWidth - 64)), math.max(64, math.min(by, screenHeight - 64)))
    
        -- Update boss bullet positions (if any)
        timer = timer + 1
        if timer % 200 == 0 then
            boss.speed = boss.speed + 50
        end
    end

    -- update player collider
    player.collider:setLinearVelocity(vx, vy)

    -- camera movement
    if scene1 then
        cam:lookAt(player.x, player.y)
    end

    if scene2 then
        cam:lookAt(player.x, player.y)
    end

end

function love.draw()
    if player.alive then
        if scene1 then
            cam:attach()
                -- draw background
                gameMap:drawLayer(gameMap.layers["Tile Layer 4"])
                gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
                gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
                gameMap:drawLayer(gameMap.layers["Tile Layer 3"])
                -- draw player animation
                player.anim:draw(player.spriteSheet, player.x - 24, player.y - 24)
                npc.animations["idle"]:draw(npc.spriteSheet, npc.x - 48, npc.y - 48, 0, 0.7)
                -- draw table of sheep
                for _, sheep in ipairs(SheepList) do
                    sheep:draw()
                end

                if player.sheepCollected >= 20 then
                    -- add static shader
                    if player.sheepCollected >= 30 then
                        scene2 = true
                        scene1 = false
                        SheepList = {} -- reset sheep list
                    end
                end
            cam:detach()
        end
        if scene2 then
            if player.sheepCollected < 40 then
                -- clear screen
                love.graphics.clear(0, 0, 0, 1)
                player.anim:draw(player.spriteSheet, player.x - 24, player.y - 24)
                -- teleport player to new scene
                if tele then
                    player.collider:setPosition(400, 200)
                    tele = false
                end
                -- bullets:draw()
                boss.draw()

                for _, sheep in ipairs(SheepList) do
                    sheep:draw()
                end

                --  draw world (see colliders)
                -- world:draw()
            else 
                scene2 = false
            end
            
        end

        gameOver = not (scene1 or scene2)
        if gameOver then
            love.graphics.clear(0, 0, 0, 1)
            love.graphics.setFont(love.graphics.newFont(24))
            love.graphics.print("You win!", 300, 200)
            love.graphics.print("Sheep Collected: " .. player.sheepCollected, 400, 300)
            love.graphics.print("Go touch some Grass :) ", 400, 400)
            sounds.boss:stop()
            sounds.win:play()
        end

        for i, _ in ipairs(player.heath) do
            love.graphics.draw(player.heathSprite, 40 * i, 10, 0, 0.5)
        end
        if player.captureSheep then
            love.graphics.setFont(love.graphics.newFont(24))
            love.graphics.print("Sheep Collected: " .. player.sheepCollected .. " / 40", 300, 15)
        end

        -- update collider position
        colliderIsHere = not restart
        if colliderIsHere then
            player.x = player.collider:getX()
            player.y = player.collider:getY()
        end

        boss.x = boss.collider:getX()
        boss.y = boss.collider:getY()
        
        if myDialogue.isActive then
            myDialogue:draw()
        end

        if bossIntro.isActive then
            bossIntro:draw()
        end 
    end

    if not player.alive then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.print("You died!", 400, 200)
        love.graphics.print("Sheep Collected: " .. player.sheepCollected, 400, 300)
        love.graphics.print("Press R to restart", 400, 400)
        restart = true
    end
end

function love.keypressed(key)
    if myDialogue then
        myDialogue:keypressed(key) -- Advance dialogue
    end
    if bossIntro then
        bossIntro:keypressed(key) -- Advance dialogue
    end

    if restart then
        if key == "r" then
            player.heath = {1, 2, 3}
            player.alive = true
            player.sheepCollected = 30
            restart = false
        end
    end
end
