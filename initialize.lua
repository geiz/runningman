-- initialize.lua

----------------------------------------------------------------
-- This file contains initializing values, easy to edit
----------------------------------------------------------------

_scale_ = 10
_gravity_ = 20
_stage_ = {w = 960, h = 640} -- Pixels in the actual game
_debugMode_ = true -- enables debug in debug.lua
_fontScale_ = 20 -- fonts for debug

_imgFolder_ = "images/"
_animFolder_ = _imgFolder.."animations/"
_audioFolder_ = "audio/"
_videoFolder_ = "video/"
_dataFolder_ = "data/"
_scriptFolder_ = "scripts/"

-- _PlayerInit_ Values
_playerAnim_ = "numbers.png"
_playerDefaultVelocity_ = 200


_bgImg_ = "testMap.png"
_tree1_ = "tree-1.png"
_tree2_ = "tree-2.png"
_tree3_ = "tree-3.png"
_rock1_ = "rock-1.png"
_mountain1_ = "mountain-1.png"
_mountain2_ = "mountain-2.png"
_bulletTexture_ = "explosion.png"

_bulletRadius_ = 5

_eLength_ = 5
_eRadius_ = 10



_worldFriction_ = 0.2


_charCode_ = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'
_fontScale_ = _screen.h/_stage.h
