-- windowcamera.lua

----------------------------------------------------------------
-- This file contains all of the world and world display code
----------------------------------------------------------------


_worldScale_ = 10
_windowScale_ = 1
_cameraScale_ = 1


local view_w = _view_w_ or MOAIEnvironment.horizontalResolution or 1200
local view_h = _view_h_ or MOAIEnvironment.verticalResolution or 800


-- Opens a window and viewport fitted to the device resolution.
function OpenViewport (window_title, view_w, view_h)

	local device_w = MOAIEnvironment.horizontalResolution or view_w
	local device_h = MOAIEnvironment.verticalResolution or view_h
	local screen_w = device_w
	local screen_h = device_h
	local view_x_offset = 0
	local view_y_offset = 0
	
	local gameAspect = view_h / view_w
	local realAspect = device_h / device_w
	
	if realAspect > gameAspect then
		screen_h = device_w * gameAspect
	end
	
	if realAspect < gameAspect then
		screen_w = device_h / gameAspect
	end

	if screen_w < device_w then
		view_x_offset = ( device_w - screen_w ) * 0.5
	end

	if screen_h < device_h then
		view_y_offset = ( device_h - screen_h ) * 0.5
	end
	
	MOAISim.openWindow ( window_title, device_w, device_h )

	local viewport = MOAIViewport.new ()
	viewport:setSize ( view_x_offset, view_y_offset,
		view_x_offset + screen_w, view_y_offset + screen_h )
	viewport:setScale ( view_w, view_h )

	viewport.w, viewport.h = screen_w, screen_h
	viewport.x, viewport.y = view_x_offset, view_y_offset

	return viewport
end

_viewport_ = OpenViewport ('Game', view_w*_windowScale_, view_h*_windowScale_)


