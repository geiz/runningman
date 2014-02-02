
-- physics.lua
-- Usable physics functions. 
-- Be sure to call PhysicsInit before using the functions.


local PhysicsConfig = nil


function PhyiscsInit2D (filename)
-- Loads all of the basic modules within phyicss

	PhysiscConfig = filename
end

function LoadPhyiscsTable2D (filename, world)
-- Loads a physics table, and creates a Box2D body for each prope name in the 
-- given physics world 
-- PhysicsTable: A table containing unique entities that contains an even set of
-- 			     x y points and/or other 


end

function CreatePhysicsBody (world, name, x, y)
-- Creates a Box2D body for the given prop name in the given physics world.
-- Initially, the body will be at position x, y.
-- Returns nil if no physics config properties exist for the given name.

	if not PhysConfig[name] then
		print("Error: No physics properties file found")
		return nil
	end

	-- Gather parameters
	local bodyType = PhysConfig[name].bodyType
	local mass = PhysConfig[name].mass
	local angularDamping = PhysConfig[name].angularDamping
	local linearDamping = PhysConfig[name].linearDamping
	local rotationalInertia = PhysConfig[name].rotationalInertia
	local fixedRotation = PhysConfig[name].fixedRotation
	if fixedRotation == nil then fixedRotation = true end
	local bullet = PhysConfig[name].bullet  -- Note: Only set this to true for very fast-moving objects
	local sensor = PhysConfig[name].sensor
	if sensor == nil then sensor = true end
	local friction = PhysConfig[name].friction        -- a fixture property, applied to all fixtures
	local restitution = PhysConfig[name].restitution  -- a fixture property, applied to all fixtures 
	
	-- Create body
	local body = world:addBody (MOAIBox2DBody[string.upper (bodyType)], x, y)
	if mass then body:setMassData (mass, rotationalInertia) end
	if angularDamping then body:setAngularDamping (angularDamping) end
	if linearDamping then body:setLinearDamping (linearDamping) end
	if fixedRotation ~= nil then body:setFixedRotation (fixedRotation) end
	if bullet then body:setBullet (bullet) end
	body.name = name