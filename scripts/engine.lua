--engine.lua

----------------------------------------------------------------
-- Contains all runtime detections.
----------------------------------------------------------------

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

-- removes an index from array and shifts everything else above index down 1.
function removeFromIndex( array, arrayLength, index )
	for i=index, arrayLength-1 do
	 	array[i] = array[i+1]
	end
    array[arrayLength] = nil
    return arrayLength - 1
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
bulletsLength = 0
bulletMAXdist = 100
            -- Bullet motion
playerActionThread = MOAICoroutine.new()
playerActionThread:run(
function ()
    while true do
    	local px,py = player.body:getPosition()
        if (isBulletTrue == true) then
            

            bulletsLength = bulletsLength + 1
            bulletsImg[bulletsLength] = newImg(_bulletTexture_, 10, 10)
            layer:insertProp(bulletsImg[bulletsLength])
    
            local pvx, pvy = player.body:getLinearVelocity()

            bullets[bulletsLength] = world:addBody( MOAIBox2DBody.KINEMATIC, px, py )
            --
            if player.body.direction == 0 then
            	bullets[bulletsLength]:setLinearVelocity(-150+pvx,0+pvy)
            elseif player.body.direction == 1 then
            	bullets[bulletsLength]:setLinearVelocity(150+pvx, 0+pvy)
            else
            	print("invalid player direction detected")
            end
            --
           
            bulletsImg[bulletsLength]:setParent(bullets[bulletsLength])
            
        end
        isBulletTrue = false     

        -- Not clearing imgs when shooting more than one at a time
        for k,v in pairs (bullets) do -- for every bullet
        	local bx, by = bullets[k]:getPosition()
            for s,t in ipairs (e) do -- for every enemy
                ex,ey = e[s].body:getPosition() 
                 
                if isCollide(ex, ey, _eRadius_, bx, by, _bulletRadius_ ) then
                    
                    layer:removeProp(bulletsImg[k])  
                    bullets[k]:destroy()  
                    bulletsLength = removeFromIndex(bullets, bulletsLength, k)


                    layer:removeProp (e[s].animIdle)
                    e[s].body:destroy()
                    _eLength_ = removeFromIndex(e, _eLength_, s)
                end
            end
			if math.abs(bx-px) > bulletMAXdist or math.abs(by-py) > bulletMAXdist then            
                layer:removeProp(bulletsImg[k])  
                bullets[k]:destroy()  
                bulletsLength = removeFromIndex(bullets, bulletsLength, k)
                 print(bulletsLength)
            end
        end        
        coroutine.yield()
    end
end )



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
        if player.platform then
            dx = dx + player.platform:getLinearVelocity()
        end
       -- if not player.platform then
       --     propDir(dx)
       -- end
        player.body:setLinearVelocity( dx, dy )
        coroutine.yield()
    end
end )
