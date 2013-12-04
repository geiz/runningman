-- actions.lua

----------------------------------------------------------------
-- This file contains all actions and abilities for player and NPC
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
--[[
function bombHandler (x, y)
    GameSurface.layer:insertProp(player.attack.timedbomb.prop)
    bombTimer = newTimer(2, function()
                                    explosionProp:setLoc(x,y)
                                    GameSurface.layer:insertProp(explosionProp)
                                    --
                                    GameSurface.layer:removeProp(player.attack.timedbomb.prop)
                                    resolveTimer = newTimer(0.5, function() 
                                                                    layer:removeProp(explosionProp) 
                                                                    --player.attack.timedbomb.attacking = false
                                                                end
                                                            , false)
                                  end
                                , false)
end]]

function PlayerJump ()
    if (player.onGround or not player.doubleJumped) then
        player.body:setLinearVelocity( player.body:getLinearVelocity(), 0 )
        player.body:applyLinearImpulse( 0, _playerDefaultVelocity_*2 )
        if not player.onGround then
            player.doubleJumped = true
        end
    end
end
-----------------

-- Fires a projectile from location of host entity
-- vx, vy are velocity in the x and y directions respectively
-- sx, sy are startx and starty locations.
function fireProjectile(vx, vy,sx,sy,tileAnim)
    local projectile = createObj(-3,3,3,-3,'projectile',tileAnim,sx,sy,dynamic)
    projectile:setLinearVelocity(vx,vy)
end