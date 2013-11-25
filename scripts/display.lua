-- display.lua


----------------------------------------------------------------
-- This file contains all of the required display functions
----------------------------------------------------------------

viewport = OpenViewport ('Metal Slug + FTL', _stage_.w, _stage_.h)

camera = MOAICamera2D.new()
camera:setScl (1 / _stage_scale_)

-- setup layers
layer = MOAILayer2D.new() -- Main playable, interactable layers
layerEff = MOAILayer2D.new() -- In front of _layer, displays effects
layerDiag = MOAILayer2D.new() -- In front of _layerEff, displays dialog
layerMenu = MOAILayer2D.new() -- In front of _layerDiag, displays menu
layerDebug = MOAILayer2D.new() -- In front of _layerMenu, for debug
layerBG1 = MOAILayer2D.new() -- "Farthest" Background Layer
layerBG2 = MOAILayer2D.new()
layerBG3 = MOAILayer2D.new() -- "closest" Background Layer (still behind _layer)
 


function InitLayers ()
	layer:setViewport(viewport)
	layerEff:setViewport(viewport)
	layerDiag:setViewport(viewport)
	layerMenu:setViewport(viewport)
	layerDebug:setViewport(viewport)
	layerBG1:setViewport(viewport)
	layerBG2:setViewport(viewport)
	layerBG3:setViewport(viewport)

	layer:setCamera(camera)
	layerEff:setCamera(camera)
	layerDiag:setCamera(camera)
	layerMenu:setCamera(camera)
	layerDebug:setCamera(camera)
	layerBG1:setCamera(camera)
	layerBG2:setCamera(camera)
	layerBG3:setCamera(camera)
	
	MOAISim.pushRenderPass(layer)
    MOAISim.pushRenderPass(layerBG1)
end

-- Starts the animation process for an already created tilemap. Time between each
-- frame is set equal and animation is looping by default
---- numFrames = number of frames in your tilemap
---- totalTime = total time in seconds you want the animation to run for
function startTileAnim (animProp, animLengthFrames, animHeightFrames, totalTime)
	local numFrames = animLengthFrames*animHeightFrames
	tempCurve = MOAIAnimCurve.new()
	print(numFrames)
	print(totalTime)
	tempCurve:reserveKeys (numFrames)
	for i = 1, numFrames do
			tempCurve:setKey(i, i*(totalTime/numFrames), i, MOAIEaseType.FLAT)
	end
	tempAnim = MOAIAnim:new()
	tempAnim:reserveLinks(1)
	tempAnim:setLink(1,tempCurve, animProp, MOAIProp2D.ATTR_INDEX)
	tempAnim:setMode (MOAITimer.LOOP)
	tempAnim:start()
end