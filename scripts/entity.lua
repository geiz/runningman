-- entity.lua
----------------------------------------------------------------
-- This file setup basic entity values for ingame NPCs
----------------------------------------------------------------

-- Creates a box shaped object 
-- type = 'dynamic', 'kinematic',static
-- entity is a box shape dynamic body 
-- size defined with 0,0 at center, (x1,y1) top left, (x2,y2) bottom right
-- if health is nil, then obj is invulnerable
function createObj (x1, y1, x2, y2, tag, tileAnim, startx, starty, type, health)
	--body = nil
	--body = world:addBody(MOAIBox2DBody.DYNAMIC, startx, starty)
	if (type == 'dynamic') then
		body = world:addBody(MOAIBox2DBody.DYNAMIC, startx, starty)
		body:setFixedRotation( false )
		body:setMassData( 80 )
		body:resetMassData()
	elseif (type == 'kinematic') then
		body = world:addBody(MOAIBox2DBody.KINEMATIC, startx, starty)
	elseif (type == 'static') then
		body = world:addBody(MOAIBox2DBody.STATIC, startx, starty)
	else
		print("Choose a Valid type in createObj")
		return
	end

	animIdle = tileAnim
	animIdle:setParent(body)
	layer:insertProp(animIdle) 
	startTileAnim(animIdle,8,8,6 )

	verts = {
		 x1, y1,
		 x1, y2,
		 x2, y2,			
		 x2, y1
	}

	polygon = body:addPolygon( verts )
  	rect = body:addRect( x1, y2, x2, y1 )
	polygon:setRestitution( 0 )
	polygon:setFriction( 0.2 )
	rect:setSensor( true )
	return {
		onGround = false,
		currentContactCount = 0,
		move = {left = false, right = false},
		verts = verts,
		body = body,
		tag = tag,
		animIdle = animIdle,
		polygon = polygon,
	  	rect = rect,
	  	health = health
	}
end
