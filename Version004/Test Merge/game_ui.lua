function ChainInGameUI (allow_switching_to_editor)
	MOAIInputMgr.device.keyboard:setCallback ( gameKeyboardEvent )
end

function ChainOutGameUI ()
	MOAIInputMgr.device.keyboard:setCallback ( nil )
end

function gameKeyboardEvent ( key, down )
	if down == true then
		--print (key, "down")
		if key == 27 then
			GoOutOfPlayMode ()
		end
	else
		--print (key, "up")
	end
end

