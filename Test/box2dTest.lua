----------------------------------------------------------------
--constants
----------------------------------------------------------------
STAGE_WIDTH = 500
STAGE_HEIGHT = 500
 
----------------------------------------------------------------
--window, viewport, layer
----------------------------------------------------------------
 

MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 2, 1, 1, 1 )

 
MOAISim.openWindow( "Box2D Testbed", STAGE_WIDTH, STAGE_HEIGHT )
 
viewport = MOAIViewport.new()
viewport:setSize( STAGE_WIDTH, STAGE_HEIGHT )
viewport:setScale( STAGE_WIDTH, STAGE_HEIGHT )
 
layer = MOAILayer2D.new()
layer:setViewport( viewport )
MOAISim.pushRenderPass( layer )
 
----------------------------------------------------------------
--info box
----------------------------------------------------------------
charcodes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            .. "0123456789 .,:;!?()&/-"
 
font = MOAIFont.new()
font:loadFromTTF( "verdana.TTF", charcodes, 7.5, 163 )
 
infoBox = MOAITextBox.new()
infoBox:setFont( font )
--infoBox:setTextSize( font:getScale ())
infoBox:setString( "Ready" )
infoBox:setRect(-STAGE_WIDTH/2, 0, 0, STAGE_HEIGHT/2)
infoBox:setYFlip( true )
layer:insertProp( infoBox )
 
----------------------------------------------------------------
--box2d world
----------------------------------------------------------------
world = MOAIBox2DWorld.new()
world:setGravity( 0, -10 )
world:setUnitsToMeters( .10 )
world:start()
layer:setBox2DWorld( world )
 
----------------------------------------------------------------
--box2d bodies
----------------------------------------------------------------
--a static body
staticBody = world:addBody( MOAIBox2DBody.STATIC )
staticBody:setTransform( 0, -150 )
--a dynamic body
dynamicBody = world:addBody( MOAIBox2DBody.DYNAMIC, -50, 0 )
--dynamicBody:setTransform( -50, 0 )
--a kinematic body
kinematicBody = world:addBody( MOAIBox2DBody.KINEMATIC )
kinematicBody:setTransform( 0, 0 ) 
 
----------------------------------------------------------------
--box2d polys and fixtures
----------------------------------------------------------------
rectFixture = staticBody:addRect( -200, -15, 200, 15 )
circleFixture = dynamicBody:addCircle( 0, 0, 20 )
hexPoly = {
  -10, 20,
  -20, 0, 
  -10, -20,
  10, -20,
  20, 0,
  10, 20,
}
tempPoly = {10, 20}
hexFixture = kinematicBody:addPolygon( tempPoly )