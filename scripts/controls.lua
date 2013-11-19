-- controls.lua

----------------------------------------------------------------
-- This file contains all player control logic
----------------------------------------------------------------

-- keyboard input handler
function onKeyboard( key, down )
    -- 'a' key
    if key == 97 then
        player.move.left = down
        player.body.anim:setScl(-1,1)
    -- 'd' key
    elseif key == 100 then
        player.move.right = down
        player.body.anim:setScl(1,1)
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
    if key == 32 and down == true then
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

MOAIInputMgr.device.keyboard:setCallback( onKeyboard )