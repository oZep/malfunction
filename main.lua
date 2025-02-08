local LoveDialogue = require "LoveDialogue"
--local DebugConsole = require "Debuging.DebugConsole"

local myDialogue

function startTask()
    myDialogue = LoveDialogue.play("dialogue.ld", {
        boxHeight = 150,
        portraitEnabled = true
    })
end

local dialogueCooldown = false

function beginContact(colliderA, colliderB, coll)
    if colliderA and colliderB then
        local aType = colliderA.collision_class
        local bType = colliderB.collision_class

        if (aType == "Player" and bType == "NPC") or (aType == "NPC" and bType == "Player") then
            if not dialogueCooldown then
                print("Player collided with NPC!")
                startTask()
                dialogueCooldown = true
                -- Set a cooldown timer (e.g., 2 seconds)
                love.timer.after(2, function() dialogueCooldown = false end)
            end
        end
    end
end


function love.load()
    anim8 = require "Animation/anim8"
    wf = require 'windfield' -- a physics library for love2d
    sti = require "sti" -- a Tiled map loader for love2d
    camera = require "camera" -- a camera library for love2d
    cam = camera()

    gameMap = sti("Assets/maps/testmap.lua")

    -- Create a world with standard gravity
    world = wf.newWorld(0, 0)
    world:addCollisionClass("Player")
    world:addCollisionClass("NPC")

    -- for scaling pixel art
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- player character
    player = {}
    player.collider = world:newBSGRectangleCollider(1410, 2230, 40, 40, 14)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player")
    player.x = 1410
    player.y = 2230 -- center of scene
    player.speed = 200
    player.spriteSheet = love.graphics.newImage("Assets/sprites/Char_002.png")
    player.grid = anim8.newGrid(48, 48, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations["down"] = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations["left"] = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations["right"] = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations["up"] = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.anim = player.animations["down"]

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


    -- boss character
    boss = {}
    boss.x = 400 - 64
    boss.y = 200 -- center of scene
    boss.speed = 1200
    boss.spriteSheet = love.graphics.newImage("Assets/sprites/97.png")
    boss.grid = anim8.newGrid(128, 128, boss.spriteSheet:getWidth(), boss.spriteSheet:getHeight())
    boss.animations = {}
    boss.anim = anim8.newAnimation(boss.grid('1-1', 1),0.1)

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(walls, wall)
        end
    end

    -- myDialogue = LoveDialogue.play("dialogue.ld", { --- essentially just play different dialogues during different phases of the game aka when character collison
    --     boxHeight = 150,
    --     portraitEnabled = true
    -- })
    
end


function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

    if myDialogue then
        myDialogue:update(dt)
        return
    end

    if player.collider:enter("NPC") then
        print("Player collided with NPC!")
        startTask()
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
    boss.anim:update(dt)
    npc.animations["idle"]:update(dt)
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
        npc.animations["idle"]:draw(npc.spriteSheet, npc.x - 48, npc.y - 48, 0, 0.7)
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
        myDialogue:keypressed(key) -- Advance dialogue
    end
end
