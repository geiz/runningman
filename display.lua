-- display.lua


----------------------------------------------------------------
-- This file contains all of the required display functions
----------------------------------------------------------------



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

	MOAISim.pushRenderPass(layer)
    MOAISim.pushRenderPass(layerBG1)
end

-- Creates and returns a static prop
function newImg (imgName, width, height)
    imgPath = _imgFolder .. imgName
    if width == nil or height == nil then
        local img = MOAIImage.new()
        img:load (imgPath)
        width, height = img:getSize()
        img = nil
    end
    local tempQuad = MOAIGfxQuad2D.new()
    tempQuad:setTexture(imgPath)
    tempQuad:setRect(-width/2, -height/2, width/2, height/2)
    local tempProp = MOAIProp2D.new()
    tempProp:setDeck (tempQuad)
    tempProp.imagename = imgPath
    return tempProp 
end

-- Creates and returns an animated img that is set in tilemap format
---- width, height = how big you want each frame to show as.
---- animLengthFrames, animHeightFrames = animation frame tiles horizontally and vertically in tilemap.
function newTileAnim (animName, width, height, animLengthFrames, animHeightFrames)
    animPath = _animFolder .. animName
    if animLengthFrames == nil or animHeightFrames == nil then
        print("Error: Specify imgName for function newTileAnim (imgName, width, height, animLengthFrames, animHeightFrames)")
    end
    local tempDeck = MOAITileDeck2D.new()
    tempDeck:setTexture (animPath)
    tempDeck:setSize(animLengthFrames, animHeightFrames)
    tempDeck:setRect (-width/2, -height/2, width/2, height/2 )

    local tempProp = MOAIProp2D.new()
    tempProp:setDeck(tempDeck)
    tempProp.imagename = animPath
    return tempProp
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