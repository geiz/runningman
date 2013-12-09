--world.lua

----------------------------------------------------------------
-- This file contains all of the world and world display code
----------------------------------------------------------------


-- Create the viewport and primary camera
view_w, view_h = 960, 640, 80*_windowScale_
viewport = OpenViewport ('Game', view_w*_windowScale_, view_h*_windowScale_)

-- Create game surfaces and tray
GameSurface = CreateLayer (viewport, GameCamera)
BackgroundSurface2 = CreateLayer (viewport, GameCamera, 0.5, 0.85)
BackgroundSurface1 = CreateLayer (viewport, GameCamera, 0.25, 0.888)
BackgroundSurface1.layer:setClearColor (1,1,1)  -- Set this surface to clear the screen

-- displays level objects
--_currentLevel_ = LoadLevel (_levelFolder_ .. _levelFile_)
--ShowLayers (GameSurface)

-- set Box2D for main gameworld
world = MOAIBox2DWorld.new()
world:setGravity(0, -_gravity_)
world:setUnitsToMeters(1/_worldScale_)
GameSurface.layer:setBox2DWorld(world)


bodies = {}
bodies.fixtures = {}
world.fixtures = {}
--[[
ground.body = world:addBody(MOAIBox2DBody.STATIC)
ground.body.tag = 'environment'
ground.verts = {} -- List of polygon groups used ingame
ground.verts.nodes = {} -- Nodes in a polygon group used ingame
ground.fixtures = {} -- Adding the polygon groups to Box2D
]]
-- Generates the verticies for each element for use in Box2D
-- and adds it to the Box2D world
function LoadPlayableVerts (world, t) 
	for i, data in pairs (t or {}) do
		local objname = data.name
		local objx = data.x
		local objy = data.y

		print(objx)
		print(objy)

		bodies [i] = world:addBody(MOAIBox2DBody.STATIC)
		bodies [i].fixtures = {}

		for j = 1, #Physics[objname].nodes, 2 do
			table.insert (bodies [i].fixtures, (objx))
			table.insert (bodies [i].fixtures, (objy))
		end
		table.insert (bodies[i].fixtures, (objx))
		table.insert (bodies[i].fixtures, (objy))

		table.insert (world.fixtures, 
			bodies[i]:addChain(bodies[i].fixtures))
		print ("inserted"..i)

	--[[	ground.verts[i] = {} 
		ground.verts[i].nodes = {} -- First value rep x, Second rep y
]]
--[[	
		-- Adds each element in Physics.nodes to objx or objy and  
		-- stores it in ground.verts.nodes
		for j = 1, #Physics[objname].nodes, 2 do
			table.insert (ground.verts[i].nodes, (objx + Physics[objname].nodes[j]))
			table.insert (ground.verts[i].nodes, (objy + Physics[objname].nodes[j+1]))
			print ("converting"..j.."  "..(objx + Physics[objname].nodes[j]))
			print ("converting"..(j+1).."  "..(objx + Physics[objname].nodes[j+1]))
		end
		-- Inserts first node one more time to connect the object fully
		table.insert (ground.verts[i].nodes, (objx + Physics[objname].nodes[1]))
		table.insert (ground.verts[i].nodes, (objy + Physics[objname].nodes[2]))

		-- Inserts physics polygon from ground.verts into ground.fixture 
		table.insert (ground.fixtures, 
			ground.body:addChain(ground.verts[i].nodes))
		print ("inserted"..i)]]
	end
end

-- Places images onto layer, using table t information
function LoadImageSurface (t, l)
	local max_priority = 0
	for i, data in ipairs (t or {}) do
		local objname = data.name
		local objx = data.x
		local objy = data.y
		local objpriority = data.priority

		local prop = CreateProp(objname)
		prop:setPriority (objpriority)
		PlaceInLayer(l, prop, objx, objy)
		--max_priority = math.max(max_Priority, objpriority + 1)
	end
end
-- Loads the verticies for all the props in a surface
--[[function LoadIntoGame (t, surface)
	local max_priority = 0
	for i, data in ipairs (t or {}) do
		-- Adds the Box2D Polygons 
		-- GetPhysicsPolygon()

		local prop = CreateProp (data.name)
		prop:setPriority (data.priority)
		PlaceInLayer (surface, prop, data.x, data.y)
		max_priority = math.max (max_priority, data.priority + 1)
	end
	return max_priority
end ]]

-- Loads the prop physics table into Physics
-- This Function should be called first.
function LoadPropPhysicsTableGame (physTable)
	Physics = {} -- declared in util.lua

	-- Loads the physics nodes
	for objectname, physinfo in pairs (physTable or {})do
		Physics[objectname] = {}
		Physics[objectname].nodes = {}

		--Stores all the values into the ground array
		for i = 1, #physinfo.nodes, 2 do
			table.insert (Physics[objectname].nodes, physinfo.nodes[i])
			table.insert (Physics[objectname].nodes, physinfo.nodes[i+1])
		end
	end
end

local all = dofile (_levelFolder_ .. _levelFile_) -- loads level file
LoadPropPhysicsTableGame(all.PhysicsTable)
--LoadPlayableVerts(world, all.GameSurface)
b = CreatePhysicsBody(world, "rock1", 0,-190)
--print(b)
--[[
LoadImageSurface(all.GameSurface, GameSurface)
LoadImageSurface(all.BackgroundSurface2, BackgroundSurface2)
LoadImageSurface(all.BackgroundSurface1, BackgroundSurface1)
--local p1 = LoadIntoGame (all.GameSurface, GameSurface)]]

MOAISim.pushRenderPass(BackgroundSurface1.layer)
MOAISim.pushRenderPass(BackgroundSurface2.layer)
MOAISim.pushRenderPass(GameSurface.layer)
