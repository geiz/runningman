--[[This module requires the following globals:
	TargetSurface
	camera
	viewport
	_priority_ (a number)
	tray (a Surface)

	PhysicsEditorOn (a boolean)

	GoIntoPlayMode ()
	-- and editor support functions
]]

mouse_x = 0
mouse_y = 0


function ChainInEditorUI ()
	pick = nil
	old_x = mouse_x
	old_y = mouse_y
	scroll_main_layer = false
	scroll_tray_layer = false
	
	if MOAIInputMgr.device.pointer then
		-- mouse input
		MOAIInputMgr.device.pointer:setCallback ( editorMouseMove )
		MOAIInputMgr.device.mouseLeft:setCallback ( editorMouseClick )
		MOAIInputMgr.device.mouseRight:setCallback ( editorMouseClickRight )
	else
		-- touch input
		MOAIInputMgr.device.touch:setCallback ( 
			function ( eventType, idx, x, y, tapCount )
				mouseMove ( x, y )
				if eventType == MOAITouchSensor.TOUCH_DOWN then
					mouseClick ( true )
				elseif eventType == MOAITouchSensor.TOUCH_UP then
					mouseClick ( false )
				end
			end
		)
	end
	MOAIInputMgr.device.keyboard:setCallback ( editorKeyboardEvent )
end

function ChainOutEditorUI ()
	if MOAIInputMgr.device.pointer then
		-- mouse input
		MOAIInputMgr.device.pointer:setCallback ( nil )
		MOAIInputMgr.device.mouseLeft:setCallback ( nil )
		MOAIInputMgr.device.mouseRight:setCallback ( nil )
	else
		-- touch input
		MOAIInputMgr.device.touch:setCallback ( nil )
	end
	MOAIInputMgr.device.keyboard:setCallback ( nil )
end

function editorKeyboardEvent ( key, down )
	if down == true then
		--print (key, "down")
		if key == 27 then  -- Esc
			GoIntoPlayMode ()
		end
		if key == 112 or key == 80 then  -- p or P
			SetPhysicsEditorMode (not PhysicsEditorOn)
		end
		if key == 115 or key == 83 then -- s or S
			SaveLevel ('level001_checkpoint.lv')
		end
	else
		--print (key, "up")
	end
end

function editorMouseMove ( x, y )
	old_x, old_y = mouse_x, mouse_y
	mouse_x, mouse_y = x, y
	
	-- Move a prop along with mouse pointer
	if pick then
		world_x, world_y = pick.layer:wndToWorld ( mouse_x, mouse_y )
		prev_x, prev_y = pick.layer:wndToWorld ( old_x, old_y )
		pick.prop:addLoc ( world_x - prev_x, world_y - prev_y )
	end
	
	-- Move a layer along with mouse pointer
	if scroll_main_layer then
		camera_x, camera_y = camera:getLoc ()
		world_x, world_y = TargetSurface.layer:wndToWorld ( mouse_x, mouse_y )
		prev_x, prev_y = TargetSurface.layer:wndToWorld ( old_x, old_y )
		camera_x = camera_x - (world_x - prev_x) / TargetSurface.parallax_x
		camera_y = camera_y - (world_y - prev_y) / TargetSurface.parallax_y
		camera:setLoc (camera_x, camera_y)
	end
	if scroll_tray_layer then
		camera_x, camera_y = tray.camera:getLoc ()
		world_x, world_y = tray.layer:wndToWorld ( mouse_x, mouse_y )
		prev_x, prev_y = tray.layer:wndToWorld ( old_x, old_y )
		camera_x = camera_x - (world_x - prev_x)
		if camera_x < viewport.w/2 - tray_h/2 then
			camera_x = viewport.w/2 - tray_h/2
		end
		tray.camera:setLoc (camera_x, camera_y)
	end
end

function editorMouseClick ( down )
	if down then
		pick = PickFromLayers (mouse_x, mouse_y)
		if pick then
			if pick == modeTile then
				-- Cycle mode.
				SetEditorMode (NextMode [EditMode])
			else
				-- We're picking up a prop from a game surface
				_priority_ = _priority_ + 1
				pick:setPriority ( _priority_ )
				pick:seekScl ( pick.basicScale, pick.basicScale, 0.125, MOAIEaseType.EASE_IN )
			end
		end
	else
		if pick then
			if pick.layerdata == tray then
				-- If in main view window, place in layer.
				if mouse_y < viewport.y + viewport.h - tray_h then
					if PhysicsEditorOn then
						-- Replacing the active physics prop with the pick
						PhysicsEditorSurface:clearProps ()
						PhysicsEditorBackground:clearProps ()
						PhysicsEditorCamera:setLoc (0,0)
						local prop = PlaceInLayer (PhysicsEditorBackground, CreateProp (pick.name), 0, 0)
						PlacePhysicsNodes (PhysicsEditorSurface, PhysicsEditorBackground, prop)
					else
						-- Dropping an ordinary game prop into game world
						local x, y = TargetSurface.layer:wndToWorld ( mouse_x, mouse_y )
						local prop = CreateProp (pick.name)
						_priority_ = _priority_ + 1
						prop:setPriority (_priority_)
						Snap (PlaceInLayer (TargetSurface, prop, x, y))
					end
				end
				-- Move back to tray
				pick:seekLoc ( pick.trayX, pick.trayY, 0.125, MOAIEaseType.EASE_IN )
				pick:seekScl ( pick.trayScl, pick.trayScl, 0.125, MOAIEaseType.EASE_IN )
			else
				if PhysicsEditorOn then
					-- Dropping a physics node
					--(unfinshed)
				else
					-- Dropping an ordinary game prop
					if mouse_y < viewport.y + viewport.h - tray_h then
						-- Let go of prop in main window.
						Snap ( pick )
					else
						-- Prop dragged back to tray. Remove from level.
						RemoveProp ( pick )
					end
				end
			end
			pick = nil
			
			
			SaveLevel (_levelFolder_..'level001.lv')
		end
	end
end

function editorMouseClickRight ( down )
	if down then
		-- Scroll main layers or tray layer, depending on click location.
		if mouse_y < viewport.y + viewport.h - tray_h then
			scroll_main_layer = true
		else
			scroll_tray_layer = true
		end
	else
		-- Stop scrolling if button was released
		scroll_main_layer = nil
		scroll_tray_layer = nil
	end
end


