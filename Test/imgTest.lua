_height_ = 1
_width_ = 4
_max_ = _height_ * _width_

MOAISim.openWindow("test", 320,480)

vp = MOAIViewport.new()
vp:setSize(320, 480)
vp:setScale(320,-480)

l = MOAILayer2D.new()
l:setViewport(vp)
MOAISim.pushRenderPass(l)

tile = MOAITileDeck2D.new()
tile:setTexture("test.png")
tile:setSize(_width_ ,_height_)
tile:setRect(-20,31,20,-31)

prop1 = MOAIProp2D.new()
prop1:setDeck(tile)
l:insertProp(prop1)

curve = MOAIAnimCurve.new()
curve:reserveKeys(_max_ )

for i=1,_max_ do
	curve:setKey(i,i*(1/_max_), i, MOAIEaseType.FLAT)
end

anim = MOAIAnim:new()
anim:reserveLinks(1)
anim:setLink(1, curve, prop1, MOAIProp2D.ATTR_INDEX)
anim:setMode(MOAITimer.LOOP)
anim:start()

--prop1:setLoc( 