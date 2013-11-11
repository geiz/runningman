-- initialize.lua

----------------------------------------------------------------
-- This file contains initializing values, easy to edit
----------------------------------------------------------------

_scale = 10
_gravity = 20
_screen = {w = 800, h = 600} -- Pixels taken on screen
_stage = {w = 640, h = 400} -- Pixels in the actual game
_debugMode = false -- enables debug in debug.lua

_imgFolder = "assets\\images\\"
_animFolder = "assets\\animations\\"

-- Tile Animation
_playerAnim = "numbers.png"

_bgImg = "bg.png"
_tree1 = "tree-1.png"
_tree2 = "tree-2.png"
_tree3 = "tree-3.png"
_rock1 = "rock-1.png"
_mountain1 = "mountain-1.png"
_mountain2 = "mountain-2.png"
_bulletTexture = "explosion.png"

_bulletRadius = 5

_eLength = 5
_eRadius = 10



-- open sim window
MOAISim.openWindow( 'Metal Slug + FTL', _screen.w, _screen.h)

_worldFriction = 0.2


_charCode = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'
_fontScale = _screen.h/_stage.h