-- main.lua

dofile("world.lua")
--dofile("display.lua")
--dofile("entity.lua")
scale = 10

-- screen dimensions
Screen = {
    w = 800,
    h = 600
}

-- stage dimensions
Stage = {
    w = 320,
    h = 200
}
-- Setup Images
imgPath = "assets\\images\\"
playerTexture = "jedi.jpg"
bgTexture = "testBG.png"


-- open sim window
MOAISim.openWindow( 'platformer_test', Screen.w, Screen.h )

-- setup viewport
viewport = MOAIViewport.new()
viewport:setSize( Screen.w, Screen.h )
viewport:setScale( Stage.w, Stage.h )
--sviewport:setOffset(-1,1)

-- setup Box2D world
world = MOAIBox2DWorld.new()
world:setGravity( 0, -20 )
world:setUnitsToMeters( 1 / scale )
--world:setDebugDrawFlags( MOAIBox2DWorld.DEBUG_DRAW_SHAPES + MOAIBox2DWorld.DEBUG_DRAW_JOINTS +
  --                       MOAIBox2DWorld.DEBUG_DRAW_PAIRS + MOAIBox2DWorld.DEBUG_DRAW_CENTERS )

-- Background layer
layer3 = MOAILayer2D.new()
layer3:setViewport (viewport)

-- main rendering layer
layer = MOAILayer2D.new()
layer:setViewport( viewport )
layer:setBox2DWorld( world )

-- char code for fonts
charCode = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'

-- to scale fonts
fontScale = Screen.h / Stage.h

-- status textbox
status = MOAITextBox.new()
status:setRect( -160 * fontScale, -100 * fontScale, 160 * fontScale, 100 * fontScale )
status:setScl( 1 / fontScale )
status:setYFlip( true )
status:setColor( 1, 1, 1 )
status:setString( 'status' )
status.font = MOAIFont.new()
status.font:load( 'verdana.ttf' )
status.font:preloadGlyphs( charCode, math.ceil( 4 * fontScale ), 72 )
status:setFont( status.font )
layer2 = MOAILayer2D.new()
layer2:setViewport( viewport )
layer2:insertProp( status )


ground.body = world:addBody( MOAIBox2DBody.STATIC, 0, -60 )
ground.body.tag = 'ground'
ground.fixtures = {
    ground.body:addChain( ground.verts1 ),
    ground.body:addChain( ground.verts2 ),
    ground.body:addChain( ground.verts3 ),
    ground.body:addChain( ground.verts4 )
}
ground.fixtures[1]:setFriction( _worldFriction )
ground.fixtures[2]:setFriction( _worldFriction )
ground.fixtures[3]:setFriction( _worldFriction )
ground.fixtures[4]:setFriction( _worldFriction )



-- Creates and returns a static prop
function newImg (imgName, width, height)
    imgPathTemp = imgPath .. imgName
    if width == nil or height == nil then
        local img = MOAIImage.new()
        img:load (imgPathTemp)
        width, height = img:getSize()
        img = nil
    end
    local tempQuad = MOAIGfxQuad2D.new()
    tempQuad:setTexture(imgPathTemp)
    tempQuad:setRect(-width/2, -height/2, width/2, height/2)
    local tempProp = MOAIProp2D.new()
    tempProp:setDeck (tempQuad)
    tempProp.imagename = imgPathTemp
    return tempProp 
end

-- Creates and returns an animated img that is set in tilemap format
---- width, height = how big you want each frame to show as.
---- animLengthFrames, animHeightFrames = animation frame tiles horizontally and vertically in tilemap.
function newTileAnim (imgName, width, height, animLengthFrames, animHeightFrames)
    imgPathTemp = imgPath .. imgName
    if animLengthFrames == nil or animHeightFrames == nil then
        print("Error: Specify imgName for function newTileAnim (imgName, width, height, animLengthFrames, animHeightFrames)")
    end
    local tempDeck = MOAITileDeck2D.new()
    tempDeck:setTexture (imgPathTemp)
    tempDeck:setSize(animLengthFrames, animHeightFrames)
    tempDeck:setRect (-width/2, -height/2, width/2, height/2 )

    local tempProp = MOAIProp2D.new()
    tempProp:setDeck(tempDeck)
    tempProp.imagename = imgPathTemp
    return tempProp
end



--BG img
background = newImg ("testBG.png",320,200)
--layer:insertProp(background)

-- setup player
player = {}
player.onGround = false
player.currentContactCount = 0
player.move = {
    left = false,
    right = false
}
player.tp = false
player.dash = false

player.platform = nil
player.doubleJumped = false
player.verts = {
    -5, 8,
    -5, -9,
    -4, -10,
    4, -10,
    5, -9,
    5, 8
}
player.body = world:addBody( MOAIBox2DBody.DYNAMIC )
player.body.tag = 'player'
player.body:setFixedRotation( false )
player.body:setMassData( 80 )
player.body:resetMassData()
player.fixtures = {
    player.body:addPolygon( player.verts ),
    player.body:addRect( -4.9, -10.1, 4.9, -9.9 )
}
player.fixtures[1]:setRestitution( 0 )
player.fixtures[1]:setFriction( 2 )
player.fixtures[2]:setSensor( true )

-- setting camera
--[[
camera = MOAITransform.new ()
layer:setCamera(camera)

fitter = MOAICameraFitter2D.new ()
fitter:setViewport ( viewport )
fitter:setCamera ( camera )

anchor = MOAICameraAnchor2D.new ()
anchor:setParent ( player.body )
fitter:insertAnchor ( anchor )
fitter:setMin(10)

fitter:start()]]

-------- player body imgs/settings
--player.body.prop = newImg("hero1-idle.png",10,16)
player.body.anim = newTileAnim("hero1-idle.png", 15, 15, 2, 1)
player.body.prop = newImg("hero1-idle.png",10,16)
player.body.anim:setParent(player.body)
layer:insertProp(player.body.anim)                                       




--------
-------- player attack imgs/settings
-- 
player.attack = world:addBody( MOAIBox2DBody.DYNAMIC )
player.attack.tag = 'bomb'
player.attack:setFixedRotation( false)
player.attack:setMassData(10)
player.attack:resetMassData()

player.attack.timedbomb = {}
player.attack.timedbomb.attacking = false
player.attack.timedbomb.prop = newImg("bomb.png",8,8)

player.attack.slash1 = {}
player.attack.slash1.attacking = false
player.attack.slash1.anim = newTileAnim("slash1-3frames.png", 15, 15, 3, 1)
--player.attack.slash1.prop = newImg("slash1-3frames.png",10,16,3,1)
--player.attack.slash1.prop:setparent(player.body)
--player.attack.prop:setParent(player.body)
isBulletTrue = false   
explosionProp = newImg ("explosion.png",6,6)


--newTimer looping.
--fireRightAway = start doing this right as function starts  
local function newTimer ( spanTime, callbackFunction, fireRightAway )
    local timer = MOAITimer.new ()
    timer:setSpan ( 0, spanTime )
    --timer:setMode ( MOAITimer.LOOP )
    timer:setListener ( MOAITimer.EVENT_STOP, callbackFunction )
    timer:start ()
    if ( fireRightAway ) then
        callbackFunction () 
    end
    return timer
end

-- handles player non-movement actions (attack, block, abilities, )
playerActionThread = MOAICoroutine.new()
playerActionThread:run(
function()
    while true do
        if (player.attack.timedbomb.attacking == true) then
            
            player.attack.timedbomb.prop:setLoc(px, py)
            layer:insertProp(player.attack.timedbomb.prop)
            ---
            bombHandler(px, py)
            ---

            player.attack.timedbomb.attacking = false
        elseif (player.attack.slash1.attacking == true) then
            currentPlayerAnim = player.attack
            player.attack.slash1.prop:setParent(player.body)
            layer:insertProp(player.attack.slash1.prop)

            animTimer = newTimer(1.5, function () layer:removeProp(explosionProp) end, false)
            player.attack.slash1.attacking = false
        end
        coroutine.yield()
    end
end )

-- player animation thread
---------------------
-- Set currentPlayerAnim as nil for now (default animation.)
-- .maxIndex = max index value of the tile map animation
-- timerspan = how fast to alternate between frames on the tilemap
currentPlayerAnim = player.body.anim
currentPlayerAnim.maxIndex = 3
currentPlayerAnim.timerSpan = 0.05
--currentPlayerAnim:setParent(player.body)
--[[
playerAnimThread = MOAICoroutine.new()
playerAnimThread:run(
function ()
    local timer = MOAITimer.new()
    timer:setSpan(currentPlayerAnim.timerSpan)
    while true do
        if currentPlayerAnim == nil then
        else
            local prevPlayerAnim = currentPlayerAnim
            local i = 0
            layer:insertProp(currentPlayerAnim)
            repeat
                currentPlayerAnim:setIndex(currentPlayerAnim:getIndex()+1)
                MOAICoroutine.blockOnAction(timer:start())
                i = i + 1
            until(prevPlayerAnim ~= currentContactCountntPlayerAnim or i >= currentPlayerAnim.maxIndex)
            if (i > currentPlayerAnim.maxIndex) then
                print( "WARNING: i > currentPlayerAnim.maxIndex in playerAnimThread")
            end
            layer.removeProp(currentPlayerAnim)
            currentPlayerAnim = nil -- resets.
        end
        coroutine.yield()
    end
end)]]

function bombHandler (x, y)
    layer:insertProp(player.attack.timedbomb.prop)
    bombTimer = newTimer(2, function()
                                    explosionProp:setLoc(x,y)
                                    layer:insertProp(explosionProp)
                                    --
                                    layer:removeProp(player.attack.timedbomb.prop)
                                    resolveTimer = newTimer(0.5, function() 
                                                                    layer:removeProp(explosionProp) 
                                                                    --player.attack.timedbomb.attacking = false
                                                          
                                                                end
                                                            , false)
                                  end
                                , false)
end


      


-- setup platforms
platforms = {}
platforms[1] = {}
platforms[1].body = world:addBody( MOAIBox2DBody.KINEMATIC, 70, -44 )
platforms[1].body.tag = 'platform'
platforms[1].body:setLinearVelocity( 20, 0 )
platforms[1].limits = {
    xMax = 130, xMin = 70,
    yMax = -43, yMin = -45 
}
platforms[1].fixtures = {
    platforms[1].body:addRect( -10, -4, 10, 4 )
}

platforms[2] = {}
platforms[2].body = world:addBody( MOAIBox2DBody.KINEMATIC, 50, -44 )
platforms[2].body.tag = 'platform'
platforms[2].body:setLinearVelocity( 0, 10 )
platforms[2].limits = {
    xMax = 51, xMin = 49,
    yMax = -44, yMin = -74
}
platforms[2].fixtures = {
    platforms[2].body:addRect( -10, -4, 10, 4 )
}

-- platform movement thread
platformThread = MOAICoroutine.new()
platformThread:run( 
    function ()
    while true do
        for k, v in ipairs( platforms ) do
            local x, y = v.body:getWorldCenter()
            local dx, dy = v.body:getLinearVelocity()
            if x > v.limits.xMax or x < v.limits.xMin then
                dx = -dx
            end
            if y > v.limits.yMax or y < v.limits.yMin then
                dy = -dy
            end
            v.body:setLinearVelocity( dx, dy )
        end
        coroutine.yield()
    end
end )

function makeBullet()
    local bullet = MOAIProp2D.new()
    bullet:setDeck( bulletProp )
    layer:insertProp( bullet )
end

            -- Bullet motion
playerActionThread = MOAICoroutine.new()
playerActionThread:run(
function ()
    while true do
        if (isBulletTrue == true) then
            local i = 0
            bulletMAXdist = 50

            bulletTexture = MOAIGfxQuad2D.new()
            bulletTexture:setTexture (explosionProp)
            bulletTexture:setRect( -5, -5, 5, 5)

            sprite = MOAIProp2D.new()
            sprite:setDeck( bulletTexture )
 
            local px,py = player.body:getPosition()
            local dx, dy = player.body:getLinearVelocity()
            --player.bulletAttack:setBullet()
            player.bulletAttack = {}

                while i < 5 do
                    player.bulletAttack[i] = world:addBody( MOAIBox2DBody.KINEMATIC, px, py )
                    local bx, by = player.bulletAttack[i]:getPosition()

                    if bx > px - bulletMAXdist and bx < px + bulletMAXdist then
                        if dx > 0 then
                            player.bulletAttack[i]:setLinearVelocity(150,0)
                        else 
                            player.bulletAttack[i]:setLinearVelocity(-150, 0)
                        end
                    else
                        player.bulletAttack[i]:destroy()
                        i = i - 1
                    end
                    sprite:setParent( player.bulletAttack[i] )
                    layer:insertProp( sprite )
                    i = i + 1
                end
            --[[
            if bx > px - bulletMAXdist and bx < px + bulletMAXdist then
                if dx > 0 then
                    player.bulletAttack:setLinearVelocity(150,0)
                else 
                    player.bulletAttack:setLinearVelocity(-150, 0)
                end
            else
                player.bulletAttack:setBullet( false )
            end 
            ]]
                
            --player.bulletAttack:setLinearVelocity(60,0)
            
        end
            isBulletTrue = false           
        coroutine.yield()
    end
end )

function performWithDelay (delay)
 local t = MOAITimer.new()
 t:setSpan( delay )
 t:start()
 end

-- player foot sensor
function footSensorHandler( phase, fix_a, fix_b, arbiter )

    if phase == MOAIBox2DArbiter.BEGIN then
        player.currentContactCount = player.currentContactCount + 1
        if fix_b:getBody().tag == 'platform' then
            player.platform = fix_b:getBody()
        end
    elseif phase == MOAIBox2DArbiter.END then
        player.currentContactCount = player.currentContactCount - 1
        if fix_b:getBody().tag == 'platform' then
            player.platform = nil
        end
    end
    if player.currentContactCount == 0 then
        player.onGround = false
    else
        player.onGround = true
        player.doubleJumped = false
    end
end
player.fixtures[2]:setCollisionHandler( footSensorHandler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END )

-- player movement thread
playerMoveThread = MOAICoroutine.new()
playerMoveThread:run( 
function ()
    while true do

        -- Player Movement Handler
        local dx, dy = player.body:getLinearVelocity()
        if player.onGround then
            if player.move.right and not player.move.left then
                dx = 50
            elseif player.move.left and not player.move.right then
                dx = -50
            else
                dx = 0
            end
        else
            if player.move.right and not player.move.left and dx <= 0 then
                dx = 25
            elseif player.move.left and not player.move.right and dx >= 0 then
                dx = -25
            end
        end
        if player.platform then
            dx = dx + player.platform:getLinearVelocity()
        end
        if not player.platform then
            propDir(dx)
        end
        player.body:setLinearVelocity( dx, dy )
        coroutine.yield()
    end
end )

function playerDash()
if player.dash then
        playerMoveThread = MOAICoroutine.new()
        playerMoveThread:run( 
            function ()
                    local dx, dy = player.body:getLinearVelocity()
                        dx = 200
                        dy = 5
                    player.body:setLinearVelocity( dx, dy )
                    coroutine.yield()
            end)
        end
end
--[[
function playerTP()
    if player.tp then
        playerMoveThread = MOAICoroutine.new()
        playerMoveThread:run( 
            function ()
                local dx, dy = player.body:getWorldCenter()
                   dx = dx + 100
                player.body:set
                coroutine.yield()
            end
        end)
    end
end
]]

-- update function for status box
statusThread = MOAICoroutine.new()
statusThread:run( 
function ()
    while true do
        local x, y = player.body:getWorldCenter()
        local dx, dy = player.body:getLinearVelocity()
        status:setString( 'x, y:   ' .. math.ceil( x ) .. ', ' .. math.ceil( y )
                     .. '\ndx, dy: ' .. math.ceil( dx ) .. ', ' .. math.ceil( dy )
                     .. '\nOn Ground: ' .. ( player.onGround and 'true' or 'false' )
                     .. '\nContact Count: ' .. player.currentContactCount
                     .. '\nPlatform: ' .. ( player.platform and 'true' or 'false' ) )
        coroutine.yield()
    end
end )

-- keyboard input handler
function onKeyboard( key, down )
    -- 'a' key
    if key == 97 then
        player.move.left = down
        player.body.prop:setScl(-1,1)
    -- 'd' key
    elseif key == 100 then
        player.move.right = down
        player.body.prop:setScl(1,1)
    end

    if key == 102 and down == true then
        player.attack.timedbomb.attacking = true
        px,py = player.body:getPosition()
    end

    if key == 103 and down == true then
        player.attack.slash1.attacking = true
        px,py = player.body:getPosition()
    end
        -- SPACE = 32, when pressed, firing a bullet.
    if key == 32 then
        isBulletTrue = true
    end

    if key == 99 then
        player.dash = down
        playerDash()
    end

    if key == 122 then
        player.tp = down
        playerTP()
    end

    -- jump
    if key == 119 and down and ( player.onGround or not player.doubleJumped ) then
        player.body:setLinearVelocity( player.body:getLinearVelocity(), 0 )
        player.body:applyLinearImpulse( 0, 80 )
        if not player.onGround then
            player.doubleJumped = true
        end
    end
end

function propDir(dx)
    if dx > 0 then
        player.body.prop:setScl(-1, 1)
    elseif dx < 0 then
        player.body.prop:setScl(1, 1)
    end
    player.body.prop:setParent(player.body)
    layer:insertProp(player.body.prop)
end

MOAIInputMgr.device.keyboard:setCallback( onKeyboard )

-- render scene and begin simulation
world:start()
MOAIRenderMgr.setRenderTable( { layer, layer2 } )


-- Executes a function with some delay (1000 = 1sec)
-----------------DOESN'T WORK :( ---------------------------
--[[
function performWithDelay ( delay, func, repeats, ... )
    local t = MOAITimer.new ()
    t:setSpan (delay/100)
    t:setListener ( MOAITimer.EVENT_TIMER_LOOP,
    function ()
        t:stop ()
        t = nil
        func ( unpack ( arg ))
        if repeats then
            if repeats > 1 then
                print(repeats.." repeats to go")
                display.performWithDelay(delay, func, repeats - 1, unpack ( arg ))
                elseif repeats == 1 then
                prnt("ended")
                elseif repeats == 0 then
                display.performWithDelay(delay, func, 0, unpack ( arg ))
                end
            end
        end
    )
    t:start ()
end

performWithDelay(50, function () 
    print("2") 
    end, 5)

local clock = os.clock
function sleep(n)
    local t0 = clock()
    while clock() - t0 <= n do end
end
----------------- THIS WORKS :) ------------------
local timer4 =  MOAITimer.new()
timer4:setSpan(0.05)
update4 = MOAICoroutine.new()
update4:run(
    function ()
        while true do
            coroutine.yield()
            
            player.body.prop:setIndex(player.body.prop:getIndex()+1)
            --performWithDelay(500, print("sfa"), 1)
            print("sda")
            MOAICoroutine.blockOnAction(timer4:start())
        end
    end
)]]

--[[
----    This function will execute a tilebased animation in playerAnimThread when "active". Animation is run based on the delay
--      between frames and indexShift. It assumes that you will go through the whole tilemap image
-- Delay = delay per frame.
-- anim = variable that holdes the tile animation.
-- active = if true, then function will execute 
-- indexShift = ...:getIndex()+x, where x is indexShift [This number default is 1]
-- indexMax = maximum integer that represents last item in an anim index.
function animHandler (delay, anim, active, indexShift, indexMax)
    if indexShift == nil then
        indexShift = 1
    end
    if active then
        local i = 0
        repeat 
            anim:setIndex(anim:getIndex()+indexShift)
            i++
        until(i >= indexMax)
        if i > indexMax then
            print("WARNING: i > indexMax")
        end
    end
end]]
