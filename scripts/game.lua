-- game.lua

dofile("initialize.lua")

extend ('util.lua')
extend ('image_loader.lua')
extend ('physics_loader.lua')
extend ('camera.lua')
extend ('world.lua')
extend ('player.lua')
 
extend ('actions.lua')
extend ('engine.lua')
extend ('game_ui.lua')
extend ("debug.lua")

-- Begins World Simulation
world:start()
MOAIInputMgr.device.keyboard:setCallback( gameKeyboardEvent )
--MOAIRenderMgr.setRenderTable( { layer, layerDebug} )