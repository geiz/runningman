-- actions.lua

----------------------------------------------------------------
-- This file contains all actions and abilities for player and NPC and npc
----------------------------------------------------------------

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

-----------------


function makeBullet()
    local bullet = MOAIProp2D.new()
    bullet:setDeck( bulletProp )
    layer:insertProp( bullet )
end

-- Fires a projectile from location of host entity
-- vx, vy are velocity in the x and y directions respectively
-- sx, sy are startx and starty locations.
function fireProjectile(vx, vy,sx,sy,tileAnim)
    local projectile = createObj(-3,3,3,-3,'projectile',tileAnim,sx,sy,dynamic)
    projectile:setLinearVelocity(vx,vy)
end