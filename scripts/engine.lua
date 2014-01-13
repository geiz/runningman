--engine.lua

----------------------------------------------------------------
-- Contains all runtime detections.
----------------------------------------------------------------



-- removes an index from array and shifts everything else above index down 1.
function removeFromIndex( array, index )
	for i=index, #array-1 do
	 	array[i] = array[i+1]
	end
    array[#array] = nil
end


-- Checks for circle collision between two objects. Returns true if collided
function isCollide(obj1x, obj1y, obj1Radius, obj2x, obj2y, obj2Radius )
    local distOfCenters = math.sqrt((obj2x-obj1x)*(obj2x-obj1x)
                                    +(obj2y-obj1y)*(obj2y-obj1y))
    local totalRadius = obj1Radius + obj2Radius
    if totalRadius < distOfCenters then
         return false
    else 
        return true 
    end
end


bullets = {}
bulletsImg = {}
bulletMAXdist = 100
function FireProjectile(layer)

    local px,py = player.body:getPosition()
    if (isBulletTrue == true) then
        
        bulletsImg[#bullets] = CreateProp ("bullet")
        layer:insertProp(bulletsImg[#bullets])

        local pvx, pvy = player.body:getLinearVelocity()

        bullets[#bullets] = world:addBody( MOAIBox2DBody.KINEMATIC, px, py )
        --
        if player.body.direction == 0 then
            bullets[#bullets]:setLinearVelocity(-150+pvx,0+pvy)
        elseif player.body.direction == 1 then
            bullets[#bullets]:setLinearVelocity(150+pvx, 0+pvy)
        else
            print("invalid player direction detected")
        end
        --
       
        bulletsImg[#bullets]:setParent(bullets[#bullets])
        
    end
    isBulletTrue = false     

    -- still working on this
    tempBullets = bullets
    for k,v in pairs (tempBullets) do -- for every bullet
        local bx, by = bullets[k]:getPosition()
        for s,t in ipairs (e) do -- for every enemy
            ex,ey = e[s].body:getPosition() 
             
            if isCollide(ex, ey, _eRadius_, bx, by, _bulletRadius_ ) then
                
                layer:removeProp(bulletsImg[k])  
                bullets[k]:destroy()  
                removeFromIndex(bullets, k)


                layer:removeProp (e[s].animIdle)
                e[s].body:destroy()
                removeFromIndex(e, s)
            end
        end
        if math.abs(bx-px) > bulletMAXdist or math.abs(by-py) > bulletMAXdist then            
            layer:removeProp(bulletsImg[k])  
            bullets[k]:destroy()  
            removeFromIndex(bullets, k)
            print(#bullets)
        end
    end        
end --[[
playerActionThread = MOAICoroutine.new()
playerActionThread:run(
function ()
    while true do
        FireProjectile(GameSurface.layer)
        coroutine.yield()
    end
end)
]]


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
player.rect:setCollisionHandler( footSensorHandler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END )

-- player movement thread
playerMoveThread = MOAICoroutine.new()
playerMoveThread:run( 
function ()
    while true do

        -- Player Movement Handler
        local dx, dy = player.body:getLinearVelocity()
        if player.onGround then
            if player.move.right and not player.move.left then
                dx = player.body.velocity
                player.body.direction = 1
            elseif player.move.left and not player.move.right then
                dx = -player.body.velocity
                player.body.direction = 0
            else
                dx = 0
            end
        else
            if player.move.right and not player.move.left and dx <= 0 then
                dx = player.body.velocity/2
                player.body.direction = 1
            elseif player.move.left and not player.move.right and dx >= 0 then
                dx = -player.body.velocity/2
                player.body.direction = 0
            end
        end
        --[[if player.platform then
           dx = dx + player.platform:getLinearVelocity()
        end]]
       -- if not player.platform then
       --     propDir(dx)
       -- end
        player.body:setLinearVelocity( dx, dy )
        coroutine.yield()
    end
end )

-- Creates a new animation thread
-- TO DO: 
-- 1. add animation wait timers.
-- 2. add animation change code
animationThread = MOAICoroutine.new()
animationThread:run (
function ()
    while(true) do
        --[[for k,#_e_ do
            _e_.prop
        end]]
        player.prop:setIndex(player.prop:getIndex()+1)
        coroutine.yield()
    end
end)