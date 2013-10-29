Physics = {}  -- filename -> physics_info
local SingleQuads = {}

function LoadPropsFromTable (t, surface)
	local max_priority = 0
	for i, data in ipairs (t) do
		x = LoadSingleImage (data.filename)
		data.image = x.image
		data.w = x.w
		data.h = x.h
		item = CopyToLayer (data, surface, data.x, data.y)
		item.prop:setPriority (data.priority)
		max_priority = math.max (max_priority, data.priority)
	end
	return max_priority
end

function GetPhysicsPolygon (physics)
	local t = {}
	for i, propdata in ipairs (physics.nodes) do
		local x, y = propdata.prop:getLoc ()
		table.insert (t, x)
		table.insert (t, y)
	end
	return t
end

function GetPropPhysicsTable ()
	local physics = {}
	for filename, phys in pairs (Physics) do
		physics[filename] = {}
		physics[filename].nodes = GetPhysicsPolygon (phys)
	end
	return physics
end

function LoadPropPhysicsTable (physics)
	Physics = {}
	for filename, physinfo in pairs (physics or {}) do
		Physics[filename] = {}
		Physics[filename].nodes = {}
		
		-- Create a draggable prop for each node on the polygon
		for i = 1, #physinfo.nodes, 2 do
			table.insert (Physics[filename].nodes, CreatePhysicsNodeProp (
				physinfo.nodes[i], physinfo.nodes[i+1]))
		end
		-- Create an edge line for each pair of nodes
		--Physics[filename].edgeProp = CreatePhysicsEdgeProp (Physics[filename])
	end
end

function LoadLevel (level_filename)
	local all = dofile (level_filename)
	local p1 = LoadPropsFromTable (all.GameSurface, GameSurface)
	local p2 = LoadPropsFromTable (all.BackgroundSurface2, BackgroundSurface2)
	local p3 = LoadPropsFromTable (all.BackgroundSurface1, BackgroundSurface1)
	LoadPropPhysicsTable (all.PhysicsTable)
	return math.max (p1, p2, p3)
end

function CreateCommonSurfaces (viewport, camera)
	GameSurface = CreateLayer (viewport, camera)
	--PhysicsEditorSurface = CreateLayer (viewport, camera)
	BackgroundSurface2 = CreateLayer (viewport, camera, 0.5, 0.85)
	BackgroundSurface1 = CreateLayer (viewport, camera, 0.25, 0.8)
	BackgroundSurface1.layer:setClearColor (1,1,1)  -- Set this surface to clear the screen
	return GameSurface, BackgroundSurface1, BackgroundSurface2
end


PropTypes = {}      -- type_key -> prop_type
PropInstances = {}  -- type_key -> table (prop_instance)

PropsByType = {}    -- key=proptype, value=series (of propdata)
LoadedImages = {}   -- key=filename, value=imagedata
local NonTextureImages = {}

LayersInEffect = {}

function ShowLayers (...)
	MOAISim.clearRenderStack ()
	for i, l in ipairs({...}) do
		if l.background then MOAISim.pushRenderPass (l.background.layer) end
		MOAISim.pushRenderPass (l.layer)
	end
	LayersInEffect = {...}
end

function CreateLayer (viewport, camera, parallax_x, parallax_y, allow_picking, pixel_alpha_picking)
	-- Creates a bundled layer with a partition and (optionally) parallax effect.
	local layerdata = {
		layer = MOAILayer2D.new (),
		partition = MOAIPartition.new (),
		allow_picking = allow_picking or true,
		pixel_alpha_picking = pixel_alpha_picking or true,
		camera = camera or MOAICamera2D.new (),
		viewport = viewport,
		props = {},
	}
	layerdata.layer:setViewport (viewport)
	layerdata.layer:setCamera (camera)
	layerdata.layer:setPartition (layerdata.partition)
	layerdata.parallax_x = parallax_x or 1
	layerdata.parallax_y = parallax_y or 1
	layerdata.layer:setParallax (layerdata.parallax_x, layerdata.parallax_y)
	
	function layerdata:clearProps ()
		self.props = {}
		self.partition:clear ()
	end
	
	return layerdata
end

function CreateTray (item_size, height)
	local t = {
		partition = MOAIPartition.new (),
		layer = MOAILayer2D.new (),
		camera = MOAICamera2D.new (), -- the tray has its own camera
		item_size = item_size,
		h = height,
		allow_picking = true,
		props = {},
	}
	t.layer:setCamera ( t.camera )
	t.layer:setPartition ( t.partition )
	return t
end

function ResetTray (tray, ...)  -- Puts a list of prop series into the tray
	tray.partition:clear ()
	tray.series = {}
	tray.propX = -tray.item_size/2
	tray.propY = 0
	tray.props = {}
	for i, seriesname in ipairs({...}) do
		AddSeriesToTray (tray, seriesname)
	end
end

function PositionTray (tray, location, viewport)
	tray.background = tray.background or
		NewColorLayer (viewport, 0.25, 0.25, 0.25, 0.5, viewport.w, tray.h)
	tray.layer:setViewport ( viewport )
	if location == "BOTTOM" then
		tray.camera:setLoc ( viewport.w/2 - tray.h/2, viewport.h/2 - tray.h/2 )
		tray.background:setLoc ( 0, -viewport.h/2 + tray_h/2 )
	else
		print ("ERROR: Bad tray location parameter in PositionTray")
	end
end

-- Creates a new prop instance from the given propdata.
function CopyToLayer (propdata, layerdata, x, y)
	-- Make a new deck and a new prop, but copy everything else.
	local item = copy (propdata)
	item.deck = MOAIGfxQuad2D.new ()
	item.deck:setTexture ( item.image )
	item.deck:setRect ( -item.w/2, -item.h/2, item.w/2, item.h/2 )
	item.prop = MOAIProp2D.new ()
	item.prop:setDeck ( item.deck )
	if x and y then item.prop:setLoc (x, y) end
	item.prop.data = item
	layerdata.partition:insertProp (item.prop)
	item.layer = layerdata.layer
	item.partition = layerdata.partition
	item.layerdata = layerdata
	-- Index prop
	layerdata.props[item] = true
	if not propdata.instances then propdata.instances = {} end
	propdata.instances[item] = true

	return item
end

function CreatePhysicsNodeProp (x, y)
	local w, h = 12, 12

	local prop = MOAIProp2D.new ()
	local scriptDeck = MOAIScriptDeck.new ()
	scriptDeck:setRect ( -w/2, -h/2, w/2, h/2 )
	scriptDeck:setDrawCallback ( function ()
			MOAIGfxDevice.setPenColor ( 0, 1, 0, 1 )
			MOAIGfxDevice.setPenWidth ( 2 )
			MOAIDraw.drawBoxOutline ( -w/2, -h/2, 0, w/2, h/2, 0 )
		end)
	prop:setDeck (scriptDeck)
	prop:setLoc (x, y)
	
	local propdata = { w = w, h = h }
	propdata.prop = prop
	propdata.prop.data = propdata
	return propdata
end

function CreatePhysicsEdgeProp (physics)
	local prop = MOAIProp2D.new ()
	local scriptDeck = MOAIScriptDeck.new ()
	scriptDeck:setRect ( -64, -64, 64, 64 )
	scriptDeck:setDrawCallback ( function ()
			MOAIGfxDevice.setPenColor ( 0, 1, 0, 1 )
			MOAIGfxDevice.setPenWidth ( 2 )
			local pointList = GetPhysicsPolygon (physics)
			table.insert (pointList, pointList[1])  -- copy first point to end so polygon is closed
			table.insert (pointList, pointList[2])
			MOAIDraw.drawLine (pointList)
		end)
	prop:setDeck (scriptDeck)
	
	local propdata = {}
	propdata.prop = prop
	propdata.prop.data = propdata
	return propdata
end

function PlacePhysicsNodes (surface, background_surface, prop)
	local physics = Physics[prop.filename] or {}
	if not physics.nodes then
		-- Create a default set of nodes
		physics.nodes = {}
		table.insert (physics.nodes, CreatePhysicsNodeProp (-prop.w/2, -prop.h/2))
		table.insert (physics.nodes, CreatePhysicsNodeProp (-prop.w/2, 0))
		table.insert (physics.nodes, CreatePhysicsNodeProp (-prop.w/2, prop.h/2))
		table.insert (physics.nodes, CreatePhysicsNodeProp (0, prop.h/2))
		table.insert (physics.nodes, CreatePhysicsNodeProp (prop.w/2, prop.h/2))
		table.insert (physics.nodes, CreatePhysicsNodeProp (prop.w/2, 0))
		table.insert (physics.nodes, CreatePhysicsNodeProp (prop.w/2, -prop.h/2))
		table.insert (physics.nodes, CreatePhysicsNodeProp (0, -prop.h/2))
	end
	if not physics.edgeProp then
		-- Create a default set of edges
		physics.edgeProp = CreatePhysicsEdgeProp (physics)
	end
	-- Insert nodes into partition
	for i, propdata in ipairs (physics.nodes) do
		surface.partition:insertProp (propdata.prop)
		surface.props[propdata] = true
		propdata.layer = surface.layer
		propdata.layerdata = surface
	end
	-- Insert edges into partition
	background_surface.partition:insertProp (physics.edgeProp.prop)
	
	Physics[prop.filename] = physics
end

-- Removes a prop from its surface
function RemoveProp (propdata)
	-- First, remove prop from the partition or layer.
	if propdata.partition then
		propdata.partition:removeProp (propdata.prop)
	else
		if propdata.layer then
			propdata.layer:removeProp (propdata.prop)
		end
	end
	-- Second, erase layer/partition/index information.
	propdata.layerdata.props[propdata] = nil
	propdata.partition = nil
	propdata.layer = nil
	propdata.layerdata = nil
end

function AlphaOk (propdata, world_x, world_y)
	local center_x, center_y = propdata.prop:getLoc ()
	local image_x = world_x - (center_x - propdata.w / 2)  -- assumes scale is 1.
	local image_y = propdata.h-(world_y - center_y + propdata.h / 2)  -- inverted y-axis.
	
	-- Check against width/height to see if inside image
	if image_x < 0 or image_y < 0 or image_x >= propdata.w or image_y >= propdata.h then
		return false
	end
	
	-- Load image (if not already loaded) and query the correct pixel
	if not NonTextureImages[propdata.filename] then
		NonTextureImages[propdata.filename] = MOAIImage.new ()
		NonTextureImages[propdata.filename]:load (propdata.filename)
	end
	r, g, b, a = NonTextureImages[propdata.filename]:getRGBA (image_x, image_y)
	if a >= 0.05 then
		return true
	else
		return false
	end
end

function PickFromLayers (mouse_x, mouse_y)
	-- Queries all layers in order, returning the chosen prop (if exists)
	for i = #LayersInEffect, 1, -1 do
		if LayersInEffect[i].allow_picking then
	
			local x, y = LayersInEffect[i].layer:wndToWorld ( mouse_x, mouse_y )
		
		
			-- Choose picking style
			if LayersInEffect[i].pixel_alpha_picking then
		
				-- Iterate through all props in the layer. Find highest-priority pick, if present.
				local highest_priority, chosen_propdata = nil, nil
				for picked_propdata in pairs (LayersInEffect[i].props) do
					if AlphaOk (picked_propdata, x, y) then
						if highest_priority == nil or
								picked_propdata.prop:getPriority() > highest_priority then
							highest_priority = picked_propdata.prop:getPriority()
							chosen_propdata = picked_propdata
						end
					end
				end
		
				if chosen_propdata then
					return chosen_propdata
				end
			else
		
				-- Ordinary picking
				local picked_prop = LayersInEffect[i].partition:propForPoint (x, y)
				if picked_prop then
					return picked_prop.data
				end
		
			end
			
		end
	end
	return nil
end

function NewSingleColorImage (r, g, b, a, w, h)
	local image = MOAIImage.new ()
	image:init (w or 8, h or 8)
	w = w or 8
	h = h or 8
	image:fillRect ( 0, 0, w, h, r, g, b, a )
	return image
end

function NewSingleColorQuad (r, g, b, a, w, h, border)
	local image = NewSingleColorImage (r, g, b, a, 8, 8, border)
	local quad = MOAIGfxQuad2D.new ()
	quad:setTexture ( image )
	quad:setRect ( -w/2, -h/2, w/2, h/2 )
	return quad
end

--[[ Creates a new prop of one color inside a single layer.
	Returns the prop itself, with the layer in its .layer element. ]]
function NewColorLayer (viewport, r, g, b, a, w, h)
	local prop = MOAIProp2D.new ()
	w = w or viewport.w
	h = h or viewport.h
	prop:setDeck ( NewSingleColorQuad (r, g, b, a, w, h) )
	local layer = MOAILayer2D.new ()
	layer:setViewport ( viewport )
	layer:insertProp ( prop )
	prop.layer = layer
	return prop
end

function AddToTray (tray, prop_type)
	-- Adds a prop of the given type to the tray. Assumes it is not already in the tray.
	-- Assumes tray.partition is where the prop will be inserted.
	local prop = prop_type.prop or MOAIProp2D.new ()
	prop_type.prop = prop
	prop:setDeck (prop_type.deck)
	tray.item_size = tray.item_size or 64          -- how big the tray icons should be
	tray.padding_size = tray.padding_size or 16    -- space between icons
	tray.propX = tray.propX or -tray.item_size/2   -- ideal position of the next icon
	tray.propY = tray.propY or 0
	-- Find a proper scale for the tray icon
	local idealScl = tray.item_size / prop_type.h  -- scale to fill height
	local propW = idealScl * prop_type.w
	if propW > tray.item_size * 2 then  -- but if it's too wide, shrink it
		idealScl = tray.item_size * 2 / prop_type.w
		propW = idealScl * prop_type.w
	end
	prop_type.trayX = tray.propX + propW/2
	prop_type.trayY = tray.propY
	prop_type.trayScl = idealScl
	prop:setLoc (prop_type.trayX, prop_type.trayY)
	prop:setScl (prop_type.trayScl)
	tray.partition:insertProp (prop)
	-- Update position for next prop
	tray.propX = tray.propX + propW + tray.padding_size
	-- Index backward to access the prop data from the prop itself (for picking)
	prop_type.prop.data = prop_type
	prop_type.layer = tray.layer
	prop_type.partition = tray.partition
	prop_type.layerdata = tray
end

function AddSeriesToTray (tray, series_name)
	local series = PropsByType[series_name] or {}
	for i, prop_type in ipairs (series) do
		AddToTray (tray, prop_type)
	end
end

function LoadProp (series, filename)
	local data = LoadedImages[filename] or LoadSingleImage(filename)
	LoadedImages[filename] = data
	if not PropsByType[series] then PropsByType[series] = {} end
	table.insert (PropsByType[series], data)
	data.series = series
	data.key = series .. ".." .. filename
	PropTypes[data.key] = data
	PropInstances[data.key] = {}
	return data
end

function LoadSingleImage (filename)
	-- Loads an image in a quad, scaled to the image's pixel width/height.
	-- Loads each image only once.
	if not LoadedImages[filename] then
		local image = MOAITexture.new ()
		image:load (filename)
		local w, h = image:getSize ()
		local deck = MOAIGfxQuad2D.new ()
		deck:setTexture (image)
		deck:setRect ( -w/2, -h/2, w/2, h/2 )
		LoadedImages[filename] = {
			image = image, w = w, h = h, deck = deck, filename = filename
		}
	end
	return LoadedImages[filename]
end
