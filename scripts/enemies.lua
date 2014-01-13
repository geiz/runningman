--enemies.lua
----------------------------------------------------------------
-- This file contains all functions for spawning enemies
----------------------------------------------------------------
-- TO DO:
-- 1. Add animation for enemies, Make use of frames in image_config 


-- setup Enemies
-- testAnim = CreateProp ("player_anim")

function CreateEnemy (x, y, type_name)
	-- Creates an enemy with the given type_name centered at (x,y), where type_name 
	-- is a key in the image config table. 

--	tempProp = CreateProp(type_name)
--	if tempProp = nil then return nil end

	-- Sets up an enemy
	-- setup player
	e = {}
	e.onGround = false
	e.currentContactCount = 0
	e.move = {
	    left = false,
	    right = false
	}

	e.platform = nil
	e.verts = {
	    -10, 10,
	    -10, -10,
	    10, -10,
	    10, 10
	} 	
	e.body = world:addBody( MOAIBox2DBody.DYNAMIC,x,y )
	e.body.tag = 'enemy'
	e.body:setFixedRotation( false )
	e.body:setMassData( 80 )
	e.body:resetMassData()
	e.body.velocity = _playerDefaultVelocity_

	e.polygon = e.body:addPolygon( e.verts )
	e.rect = e.body:addRect( -10, -10, 10, 10 )
	e.polygon :setRestitution( 0 ) -- valid value between 0 - 1
	e.polygon :setFriction( 1 )
	e.rect:setSensor( true )
	e.body.direction = 0 -- 0 = left, 1 = right

	e.prop = CreateProp(type_name)
	e.prop:setParent(e.body)
	GameSurface.partition:insertProp (e.prop)

	--return e
end
--[[
for i=1, #e do
	e[i] = createObj(-10,10, 10,-10, 'enemy', CreateProp("tree1small") , 20*i, 20*i, 'dynamic', 1)
end
e1 = createObj(-10,10, 10,-10, 'enemy', testAnim, -20, 20, 'kinematic')
e2 = createObj(-10,10, 10,-10, 'enemy', testAnim, 0, 20, 'static')
--enemy = createEntity(-10,10, 10,-10, 'enemy', testAnim, -20, -20)
]]
