local LoveDialogue = require "LoveDialogue"
--local DebugConsole = require "Debuging.DebugConsole"

local myDialogue

function love.load()
    anim8 = require "Animation/anim8"
    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- player character
    player = {}
    player.x = 400
    player.y = 200 -- center of scene
    player.speed = 200
    player.spriteSheet = love.graphics.newImage("Assets/sprites/Char_002.png")
    player.grid = anim8.newGrid(48, 48, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations["down"] = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations["left"] = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations["right"] = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations["up"] = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.anim = player.animations["down"]

    -- background
    background = love.graphics.newImage("Assets/background/11.png")

    -- myDialogue = LoveDialogue.play("dialogue.ld", { --- essentially just play different dialogues during different phases of the game aka when character collison
    --     boxHeight = 150,
    --     portraitEnabled = true
    -- })
    
end


function love.update(dt)
    local isMoving = false
    -- move player
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt 
        player.anim = player.animations["right"]
        isMoving = true
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        player.x = player.x - player.speed  * dt
        player.anim = player.animations["left"]
        isMoving = true
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.y = player.y + player.speed  * dt
        player.anim = player.animations["down"]
        isMoving = true
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        player.y = player.y - player.speed  * dt
        player.anim = player.animations["up"]
        isMoving = true
    end
    if not isMoving then
        player.anim:gotoFrame(2)
    end
    -- update player animation
    player.anim:update(dt)

    -- Clamp player position to stay within screen bounds
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    player.x = math.max(0, math.min(player.x, screenWidth - 48))
    player.y = math.max(0, math.min(player.y, screenHeight - 48))

    -- if myDialogue then
    --     myDialogue:update(dt)
    -- end
end

function love.draw()
    -- draw background
    love.graphics.draw(background, 0, 0)

    -- draw player animation
    player.anim:draw(player.spriteSheet, player.x, player.y)


    -- Draw the square if it exists and is visible
    if myDialogue then
        myDialogue:draw()
    end
end

function love.keypressed(key)
    if myDialogue then
        myDialogue:keypressed(key)
    end
end