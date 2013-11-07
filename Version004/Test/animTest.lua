----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc.
-- All Rights Reserved.
-- http://getmoai.com
----------------------------------------------------------------
_max = 8
_max2 = 8
MOAISim.openWindow ( "animTest", 320, 480)

viewport = MOAIViewport.new ()
viewport:setSize ( 320, 480 )
viewport:setScale ( 320, -480 )
viewport:setOffset(-1,1)


layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

tile = MOAITileDeck2D.new ()
tile:setTexture ( "numbers.png" )
tile:setSize ( _max, _max2)
tile:setRect ( -40, 40, 40, -40 )

prop1 = MOAIProp2D.new()
prop1:setDeck(tile)
layer:insertProp(prop1)

curve = MOAIAnimCurve.new ()
curve:reserveKeys (_max)
for i = 2, _max do
	curve:setKey(i, i*(8/_max), i, MOAIEaseType.FLAT)
end

anim = MOAIAnim:new ()
anim:reserveLinks ( 1 )
anim:setLink ( 1, curve,prop1, MOAIProp2D.ATTR_INDEX )
anim:setMode ( MOAITimer.LOOP )
anim:start ()

prop1:setLoc(100,100)

MOAIUnitzSystem.initialize()

sound = MOAIUntzSound.new()
sound:load( 'jess.mp3')
sound:setVolume(1)
sound:setLooping(false)
sound:play()