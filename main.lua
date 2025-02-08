local LoveDialogue = require "LoveDialogue"
--local DebugConsole = require "Debuging.DebugConsole"

local myDialogue

function love.load()
    anim8 = require "Animation/anim8"
    wf = require 'windfield' -- a physics library for love2d
    sti = require "sti" -- a Tiled map loader for love2d
    camera = require "camera" -- a camera library for love2d
    cam = camera()

    gameMap = sti("Assets/maps/testmap.lua")

    -- Create a world with standard gravity
    world = wf.newWorld(0, 0)

    -- for scaling pixel art
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- player character
    player = {}
    player.collider = world:newBSGRectangleCollider(720, 1596, 40, 40, 14)
    player.collider:setFixedRotation(true)
    player.x = 740
    player.y = 1596 -- center of scene
    player.speed = 200
    player.spriteSheet = love.graphics.newImage("Assets/sprites/Char_002.png")
    player.grid = anim8.newGrid(48, 48, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations["down"] = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations["left"] = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations["right"] = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations["up"] = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.anim = player.animations["down"]

    -- boss character
    boss = {}
    boss.x = 400 - 64
    boss.y = 200 -- center of scene
    boss.speed = 1200
    boss.spriteSheet = love.graphics.newImage("Assets/sprites/97.png")
    boss.grid = anim8.newGrid(128, 128, boss.spriteSheet:getWidth(), boss.spriteSheet:getHeight())
    boss.animations = {}
    boss.anim = anim8.newAnimation(boss.grid('1-1', 1),0.1)
    
    -- background
    background = love.graphics.newImage("Assets/maps/TinySwords/Terrain/Water/Water.png")

    -- myDialogue = LoveDialogue.play("dialogue.ld", { --- essentially just play different dialogues during different phases of the game aka when character collison
    --     boxHeight = 150,
    --     portraitEnabled = true
    -- })
    
end


function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

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
    boss.anim:update(dt)
    world:update(dt)

    -- Clamp player collider position to stay within screen bounds
    -- local screenWidth = love.graphics.getWidth()
    -- local screenHeight = love.graphics.getHeight()
    -- local px, py = player.collider:getPosition()
    -- px = math.max(24, math.min(px, screenWidth - 24))
    -- py = math.max(24, math.min(py, screenHeight - 24))
    -- player.collider:setPosition(px, py)


    -- update player collider
    player.collider:setLinearVelocity(vx, vy)

    -- camera movement
    cam:lookAt(player.x, player.y)

    -- if myDialogue then
    --     myDialogue:update(dt)
    -- end
end

function love.draw()
    
    cam:attach()
        -- draw background
        gameMap:drawLayer(gameMap.layers["Tile Layer 4"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 3"])
        -- draw player animation
        player.anim:draw(player.spriteSheet, player.x - 24, player.y - 24)
        -- boss.anim:draw(boss.spriteSheet, boss.x, boss.y)
        -- draw world (see colliders)
        world:draw()
    cam:detach()



    -- update collider position
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    if myDialogue then
        myDialogue:draw()
    end
end

function love.keypressed(key)
    if myDialogue then
        myDialogue:keypressed(key)
    end
end