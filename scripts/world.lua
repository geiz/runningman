--world.lua

----------------------------------------------------------------
-- This file contains all of the world and world display code
----------------------------------------------------------------

dofile ("windowdisplay.lua")

_gravity_ = 20
_stage_scale_ = 1   -- scaling factor applied to window (should be 1 for mobile/fullscreen)
_stage_ = { w = 960, h = 640 } -- Pixels in the game (adjustment of display size is automatic)
_debugMode_ = true -- enables debug in debug.lua
_fontScale_ = 20 -- fonts for debug