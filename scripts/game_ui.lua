function ChainInGameUI (allow_switching_to_editor)
	MOAIInputMgr.device.keyboard:setCallback ( gameKeyboardEvent )
end

function ChainOutGameUI ()
	MOAIInputMgr.device.keyboard:setCallback ( nil )
end

function gameKeyboardEvent ( key, down )

--if down == true then    
	    -- 'a' key
    if key == 97 then
        print('left')
        player.move.left = down
        --player.body.anim:setScl (-player.body.anim.basicScale, player.body.anim.basicScale)
    -- 'd' key
    elseif key == 100 then
        print('right')
        player.move.right = down
        --player.body.anim:setScl (player.body.anim.basicScale, player.body.anim.basicScale)
    end

    if key == 102 and down == true then
        --player.attack.timedbomb.attacking = true
        px,py = player.body:getPosition()
    end

    if key == 103 and down == true then
     --   player.attack.slash1.attacking = true
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
    if key == 119 and down then
        PlayerJump()
    end
	--print (key, "down")
	if key == 27 then
		GoOutOfPlayMode ()
	end
	--print (key, "up")

end

