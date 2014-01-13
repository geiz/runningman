-- game.lua

dofile("initialize.lua")

extend ("util.lua")
extend ("image_loader.lua")
extend ('camera.lua')
extend ('world.lua')
extend ('player.lua')
extend ('enemies.lua')
CreateEnemy (25,25,'tileB2')
 
extend ('actions.lua')
extend ('engine.lua')
extend ('game_ui.lua')
extend ("debug.lua")

-- Begins World Simulation
world:start()
MOAIInputMgr.device.keyboard:setCallback( gameKeyboardEvent )
--MOAIRenderMgr.setRenderTable( { layer, layerDebug} )