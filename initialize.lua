-- initialize.lua

----------------------------------------------------------------
-- This file contains initializing values, easy to edit
----------------------------------------------------------------

_worldScale_ = 10
_windowScale_ = 1
_cameraScale_ = 1
_gravity_ = 20
_stage_scale_ = 1   -- scaling factor applied to window (should be 1 for mobile/fullscreen)
_stage_ = { w = 960, h = 640 } -- Pixels in the game (adjustment of display size is automatic)
_debugMode_ = true -- enables debug in debug.lua
_fontScale_ = 20 -- fonts for debug

_imgFolder_ = "images/"
_animFolder_ = _imgFolder_.."animations/"
_audioFolder_ = "audio/"
_videoFolder_ = "video/"
_dataFolder_ = "data/" -- referene data files (save, load, etc) 
_scriptFolder_ = "scripts/"
_levelFolder_ = "working_levels/"
_levelFile_ = "level001.lv"
_physicsConfigFile_ = "physics_config.lua"
_physicsEditorFile_ = _dataFolder_ .. "autogen_physics.lua"

-- _PlayerInit_ Values
_playerDefaultVelocity_ = 175


-- enemy values
_e_ = {} -- Starts Enemy Array


_bulletRadius_ = 5


_eRadius_ = 10


_worldFriction_ = 0.2


_charCode_ = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'

function extend (fileName)
	dofile("scripts/"..fileName)
end

function error (message, ...)
-- Writes a message to stderr. If extra arguments are supplied, the message is formatted.
	local arg_count = select ('#', ...)
	if arg_count > 0 then
		io.stderr:write (string.format (message, ...) .. "\n")
	else
		io.stderr:write (message .. "\n")
	end
end
