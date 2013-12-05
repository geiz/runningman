-- This file contains functions to create physics bodies.

-- Make sure the physics world exists
_world_ = _world_ or MOAIBox2DWorld.new ()

-- Load configuration files
local PhysConfig = dofile (_physicsConfigFile_)
local PhysAutogen = dofile (_physicsEditorFile_)


function GetPhysicsPolygon (name, index)
-- Gets fixture table for object name from autogen file.
-- Returns fixture at key "index" (default 1). If doesn't exist, returns nil.
	if not PhysAutogen[name] then return nil end
	return PhysAutogen[name][index or 1]
end

function SetPhysicsPolygon (name, index, polygon)
-- Sets a fixture table for object name from autogen file.
-- The polygon is stored by reference, so future changes to polygon data
--  are automatically visible without another call to this function.
	if not PhysAutogen[name] then PhysAutogen[name] = {} end
	PhysAutogen[name][index or 1] = polygon
end

function SavePhysicsInfo ()
	saveTable (PhysAutogen, _physicsEditorFile_)
end

function CreatePhysicsBody (world, name, x, y)
-- Creates a Box2D body for the given prop name in the given physics world.
-- Initially, the body will be at position x, y.
-- Returns nil if no physics config properties exist for the given name.

	if not PhysConfig[name] then
		return nil
	end
	
	-- Gather parameters
	local bodyType = PhysConfig[name].bodyType
	local mass = PhysConfig[name].mass
	local angularDamping = PhysConfig[name].angularDamping
	local linearDamping = PhysConfig[name].linearDamping
	local rotationalInertia = PhysConfig[name].rotationalInertia
	local fixedRotation = PhysConfig[name].fixedRotation
	if fixedRotation == nil then fixedRotation = true end   -- fixedRotation defaults to true
	local bullet = PhysConfig[name].bullet     -- Note: Only set bullet to true for very fast-moving objects
	local sensor = PhysConfig[name].sensor
	if sensor == nil then sensor = true end                 -- sensor defaults to true
	local friction = PhysConfig[name].friction
	local restitution = PhysConfig[name].restitution
	
	-- Create body
	local body = world:addBody (MOAIBox2DBody[string.upper (bodyType)], x, y)
	if mass then body:setMassData (mass, rotationalInertia) end
	if angularDamping then body:setAngularDamping (angularDamping) end
	if linearDamping then body:setLinearDamping (linearDamping) end
	if fixedRotation ~= nil then body:setFixedRotation (fixedRotation) end
	if bullet then body:setBullet (bullet) end
	body.name = name
	
	if not PhysAutogen[name] then
		error ("WARNING: Physics body '%s' has no fixtures in autogen file!", name)
		return body
	end
	
	-- Load physics fixtures from autogen file.
	for fixtureName, fixtureConfig in pairs (PhysAutogen[name]) do
		if type (fixtureConfig) == 'table' then
			body.fixtures = createEdgeFixtures (body, fixtureConfig, sensor, friction, restitution)
		end
	end
	
	return body
end

function createEdgeFixtures (body, polygon, sensor, friction, restitution)
-- Adds a series of fixtures to the body.
-- There will be one chain fixture for each sequence of edges with the same type.
-- Each fixture will have a .type element containing the edge type.
-- See getEdgeTypes for more info.

	local edgeTypes = getEdgeTypes (polygon)
	local fixtures = {}
	
	-- Loop invariant: n_start to n_end inclusive are the edges in next chain
	-- We test edgeTypes[n_end+2] to see if next edge has a different type,
	--   in which case we create a chain fixture and move to the next edge.
	--   On the last iteration, edgeTypes[n_end+2] is nil, guaranteeing all edges are accounted for.
	local n_start = 1
	for n_end = 1, #edgeTypes, 2 do
		if edgeTypes[n_end+2] ~= edgeTypes[n_end] then  -- changing edge types?
			local fixture = addFixtureChain (body, polygon, n_start, n_end)
			fixture.type = edgeTypes[n_start]
			if sensor ~= nil then fixture:setSensor (sensor) end
			if friction then fixture:setFriction (friction) end
			if restitution then fixture:setRestitution (restitution) end
			table.insert (fixtures, fixture)
			n_start = n_end + 2   -- start next fixture at next edge
		end
	end
	return fixtures
end

function getEdgeTypes (polygon)
-- Returns a list where each edge in polygon is classified as:
-- "WALL", "GROUND", "CEILING", or "SLOPE". See edgeType for descriptions.
-- Returned list is same length as polygon, where item n is
--   the type of the edge from (n,n+1) to (n+2,n+3).
	local edgeTypes = {}
	-- Loop until all edges have been assigned a type.
	local n = 1
	local lastType = nil
	while edgeTypes[n] == nil do
		local t = edgeType (polygon, n) or lastType  -- if nil, default to lastType
		edgeTypes[n] = t    -- set edge type on both coordinate indexes
		edgeTypes[n+1] = t
		lastType = t
		n = n + 2; if n > #polygon then n = 1 end  -- go to next edge
	end
	return edgeTypes
end


---[[ "PRIVATE" functions below this point ]]

function addFixtureChain (body, polygon, n_start, n_end)
-- Creates a chain fixture for the given body, with the first
-- coordinate at (n_start,n_start+1) and last coordinate (n_end+2,n_end+3).
-- Assumes n_start <= n_end.
	--print ("FIXTURE CHAIN")
	local chain = {}
	for n = n_start, n_end + 2, 2 do
		local m = n; if m > #polygon then m = 1 end
		--print (n,m,polygon[m],polygon[m+1])
		table.insert (chain, polygon[m])
		table.insert (chain, polygon[m+1])
	end
	return body:addChain (chain)
end

function edgeType (polygon, n)
-- Returns the type of the edge at index n in polygon is wall, ground, ceiling, or slope.
-- WALL is mostly vertical, at least 3x taller than wide.
-- GROUND is mostly horizontal, at least 3x wider than tall.
-- SLOPE is steeply angled ground.
-- CEILING is anything that's not a WALL, GROUND, or SLOPE.
-- nil is returned if edge is zero-length.
	local m = n + 2   -- m is the next point on the polygon
	if m > #polygon then  -- wrap around, if needed
		m = 1
	end
	
	-- Test for edge type.
	local x0, y0, x1, y1 = polygon[n], polygon[n+1], polygon[m], polygon[m+1]
	if x0 == x1 and y0 == y1 then return nil end  -- zero-length edge - can't determine type.
	
	-- Is it a wall?
	local height = math.abs (y1 - y0)
	local width = math.abs (x1 - x0)
	if height >= width * 3 then return "WALL" end
	
	-- Is it a ceiling?
	if edgeIsCeiling (polygon, n) then return "CEILING" end
	
	-- Is it ground or slope?
	if width >= height * 3 then return "GROUND" end
	return "SLOPE"
end

function edgeIsCeiling (polygon, n)
-- Returns true if the edge at index n of the polygon is a ceiling (bottom of polygon).

	local m = n + 2   -- m is the next point on the polygon
	if m > #polygon then  -- wrap around, if needed
		m = 1
	end
	-- Find centre point of edge.
	local cx, cy = (polygon[n] + polygon[m])/2, (polygon[n+1] + polygon[m+1])/2
	
	-- Check every edge, counting up how many edges are above and below centre point
	local above, below = 0, 0
	for i = 1, #polygon, 2 do
		if i ~= n then  -- skip the current edge
			local j = i + 2   -- m is the next point on the polygon
			if j > #polygon then  -- wrap around, if needed
				j = 1
			end
			-- Get intersection type
			local intersect_type = verticalIntersect (cx, cy,
				polygon[i], polygon[i+1], polygon[j], polygon[j+1])
			if intersect_type == "ABOVE" then
				above = above + 1
			end
			if intersect_type == "BELOW" then
				below = below + 1
			end
		end
	end

	-- If an odd number of edges are above (and even below), this is a ceiling.
	if above % 2 == 1 and below % 2 == 0 then
		return true
	end

	-- If an even number of edges are above (and odd below), this is NOT a ceiling.
	if above % 2 == 0 and below % 2 == 1 then
		return false
	end

	-- Some numerical weirdness happened. Guess based on how many above/below.
	if above > below then
		error ("WARNING: Numerical weirdness in edgeIsCeiling. Guessing edge is ceiling.")
		return true
	end
	if above < below then
		error ("WARNING: Numerical weirdness in edgeIsCeiling. Guessing edge is not ceiling.")
		return false
	end
	error ("ERROR: Severe numerical weirdness in edgeIsCeiling. Assuming edge is not ceiling.")
	return false
end

function verticalIntersect (sx, sy, x0, y0, x1, y1)
-- Tests whether a vertical line through sx, sy intersects with the
-- line segment x0, y0 to x1, y1.
-- If intersecting, returns whether the segment is ABOVE or BELOW sy.
	if x0 > x1 then  -- swap coordinates to make sure x0 <= x1
		x0, y0, x1, y1 = x1, y1, x0, y0
	end
	if sx < x0 or sx >= x1 then  -- no intersection
		--[[ Implementation Note: the point at x0 is probably the x1 of an adjacent
			segment, and vice versa. To make sure each intersection is counted
			exactly once when sx == x0 or sx == x1, the intersection range
			includes x0, but does not include x1. ]]
		return nil
	end
	-- Find y-intersect
	local y_intersect = nil
	if x0 ~= x1 then
		y_intersect = (y1 - y0) * (sx - x0) / (x1 - x0) + y0  -- normal case
	else
		y_intersect = (y1 - y0) * 0.5 + y0  -- special case: vertical line segment
	end
	-- Is y_intersect above or below sy?
	if y_intersect < sy then
		return "BELOW"
	else
		return "ABOVE"
	end
end
