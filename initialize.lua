-- initialize.lua
-- This file contains all the filepaths, and basic functions for intitialization of game.
-- This also contains some fundamental global variables in regards to where files are.
-- * global variables denoted with "_" as prefix and suffix


-- File Locations
_imgFolder_ = "graphics/"
_animFolder_ = _imgFolder_ .. "animation/"
_soundFolder_ = "sounds/"
_dataFolder_ = "data/" -- referene data files (config, level, etc) 
_scriptFolder_ = "scripts/"
_libFolder_ = _scriptFolder_ .. "opplib/"
_levelFile_ = "current-level.lv"

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