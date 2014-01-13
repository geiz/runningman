-- camera.lua

----------------------------------------------------------------
-- Game Camera Code
----------------------------------------------------------------

-- Camera is located in 'player.lua'
GameCamera = MOAICamera2D.new ()
--EditorCamera:setLoc ( viewport.w/2, viewport.h/2 - tray_h )
GameCamera:setScl (1 / _cameraScale_)
GameCamera:setFarPlane ()
