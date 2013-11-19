-- game.lua

function extend (fileName)
	dofile("scripts/"..fileName)
end
dofile("initialize.lua")

extend ("util.lua")
extend ("image_loader.lua")
extend ("display.lua")
background = CreateProp ("bgImg")
--layer:insertProp(background)
extend ("entity.lua")
extend ("world.lua")
extend ("player.lua")
extend ("enemies.lua")

InitLayers ()

layer:setBox2DWorld(world) -- box2D physics for the main playable layer

isBulletTrue = false   
explosionProp = CreateProp ("explosion1")

layer:insertProp(player.body.anim)  
startTileAnim(player.body.anim,8,8,6 )


function abs(num)
    if num < 0 then
        return -num
    else
        return num
    end
end


--newTimer looping.
--fireRightAway = start doing this right as function starts  
function newTimer ( spanTime, callbackFunction, fireRightAway )
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



-- setup platforms
--[[platforms = {}
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
]]

    
extend ("debug.lua")
extend ("controls.lua")
extend ("actions.lua")
extend ("engine.lua")





-- render scene and begin simulation
world:start()
MOAIRenderMgr.setRenderTable( { layer, layerDebug} ) -- all rendered layers
