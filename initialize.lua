-- initialize.lua

----------------------------------------------------------------
-- This file contains initializing values, easy to edit
----------------------------------------------------------------

_scale_ = 10
_gravity_ = 20
_stage_scale_ = 1   -- scaling factor applied to window (should be 1 for mobile/fullscreen)
_stage_ = { w = 960, h = 640 } -- Pixels in the game (adjustment of display size is automatic)
_debugMode_ = true -- enables debug in debug.lua
_fontScale_ = 20 -- fonts for debug

_imgFolder_ = "images/"
_animFolder_ = _imgFolder_.."animations/"
_audioFolder_ = "audio/"
_videoFolder_ = "video/"
_dataFolder_ = "data/" -- reference data files (save, load, etc) 
_scriptFolder_ = "scripts/"
_levelFolder_ = "working_levels/"
_levelFile_ = "level001.lv"

-- _PlayerInit_ Values
_playerDefaultVelocity_ = 200

_bulletRadius_ = 5

_eLength_ = 5
_eRadius_ = 10


_worldFriction_ = 0.2


_charCode_ = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'

function extend (fileName)
	dofile("scripts/"..fileName)
end

local errorsIssued = {}

function error (message, ...)
-- Writes a message to stderr. If extra arguments are supplied, the message is formatted.
-- Only writes each error once.
	local arg_count = select ('#', ...)
	if arg_count > 0 then
		message = string.format (message, ...)
	end
	if not errorsIssued[message] then
		errorsIssued[message] = true
		io.stderr:write (message)
		io.stderr:write ("\n")
	end
end
