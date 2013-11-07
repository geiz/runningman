-- Function list + DEF:


--[[WINDOWS, VIEWPORTS, LAYERS]]
-- initiallizes a new window
MOAISim.openWindow("Hello World Window", 320, 480)cdc	cdDC	

-- 320, 480 size and 10, 15 scale will give pixel size of 32, 32. (means each pixel shown on the screen is worth 32x32 of world units)
viewport = MOAIViewport.new() -- area of screen a player would view
viewport:setSize(320, 480) -- size on screen
viewport:setScale(10, -15)  -- Inverts the y axis of viewport, size ingame
viewport:setOffset(-1,1) -- Moves projection system one half to left and one half up

layer = MOAILayer2D.new() -- Display objects rendered onto layers
layer:setViewport(viewport) 

MOAUSum.pushRanderPass(layer) -- pushes to render stack to be rendered

--[[GRAPHICS]]
-- prop = scene graph object, combines img and location on surface
-- deck = aka set, holds props in a stack
gfxquad1 = MOAIGfxQuad2D.new() -- single textured quad
gfxquad2 = MOAIGfxQuadDeck2D.new() -- array of textured quads, aka sprite sheet
gfxquad3 = MOAIGfxQuadListDeck2D.neW() -- array of lists of textured quads. Advance sprite sheets
mesh = MOAIMesh.new() -- custom vertex buffer object (for 3D)
stretchPatch = MOAIStretchPathch2D.new() -- single patch with stretchable row and collumn
tileDeck = MOAITileDeck2D.new() -- creates tile map and sprite sheets that are accessed via index. sheet divided into nxm sheets. frame animation

gfxquad1:setTexture("myTexture.png") -- creates texture of img
gfxquad1:setRect(-32,-32,32,32) -- size of img rendered

prop = MOAIProp2D.new() -- prop to display quad.
prop:setDeck(gfxquad1) 
prop:setLoc(32,32)
layer:insertProp(prop) -- renders prop to a layer

theImage = MOAIImage.new()
theImage:load("myImage2.png")

--[[TEXT, FONTS]]
charcodes = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _+-()[]{}|\/?.,<>!~`@#$%^&*\'":;'
font = MOAIFont.new()
font:loadFromTTF 'arial.ttf', charcodes, 12,163)
