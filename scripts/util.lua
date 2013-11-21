ItemInfo = {}

local ActiveLayers = {}

-- Opens a window and viewport fitted to the device resolution.
function OpenViewport (window_title, view_w, view_h)

	local device_w = MOAIEnvironment.horizontalResolution or view_w
	local device_h = MOAIEnvironment.verticalResolution or view_h
	local screen_w = device_w
	local screen_h = device_h
	local view_x_offset = 0
	local view_y_offset = 0
	
	local gameAspect = view_h / view_w
	local realAspect = device_h / device_w
	
	if realAspect > gameAspect then
		screen_h = device_w * gameAspect
	end
	
	if realAspect < gameAspect then
		screen_w = device_h / gameAspect
	end

	if screen_w < device_w then
		view_x_offset = ( device_w - screen_w ) * 0.5
	end

	if screen_h < device_h then
		view_y_offset = ( device_h - screen_h ) * 0.5
	end
	
	MOAISim.openWindow ( window_title, device_w, device_h )

	local viewport = MOAIViewport.new ()
	viewport:setSize ( view_x_offset, view_y_offset,
		view_x_offset + screen_w, view_y_offset + screen_h )
	viewport:setScale ( view_w, view_h )

	viewport.w, viewport.h = view_w, view_h
	viewport.x, viewport.y = view_x_offset, view_y_offset

	return viewport
end

function SetVisibleLayers (list)
	MOAISim.clearRenderStack ()
	for i, l in ipairs(list) do
		if l.background then MOAISim.pushRenderPass (l.background.layer) end
		MOAISim.pushRenderPass (l.layer)
	end
end

function NewLayer (viewport, camera, parallax_x, parallax_y)
	-- Creates a partition that holds the layer.
	local partition = MOAIPartition.new ()
	partition.layer = MOAILayer2D.new ()
	partition.layer:setViewport (viewport)
	partition.layer:setCamera (camera)
	partition.layer:setPartition (partition)
	partition.partition = partition
	if parallax_x then
		parallax_y = parallax_y or 1
		partition.layer:setParallax (parallax_x, parallax_y)
	end
	return partition
end

function NewTray (tray_h, viewport)
	local t = {
		partition = MOAIPartition.new (),
		layer = MOAILayer2D.new (),
		camera = MOAICamera2D.new (), -- the tray has its own camera
		background_layer = MOAILayer2D.new (),
		items = {},
		item_count = 0,
		
		add = function (self, item, slot)
			if self.items[item] ~= nil then self:remove (item) end
			self.items[item] = true
			item.layer = self.layer
			item.partition = self.partition
			if slot then
				item.slot = slot
			else
				item.slot = self.item_count
				self.item_count = self.item_count + 1
			end
			item.trayX, item.trayY = item.slot * tray_h, 0
			item.trayScl = (tray_h * 0.80) / item.h
			item.fromTray = true
			item.prop:setLoc (item.trayX, item.trayY)
			item.prop:setScl (item.trayScl)
			self.partition:insertProp (item.prop)
			return item
		end,
		remove = function (self, item)
			self.items[item] = nil
			item.layer = nil
			item.fromTray = nil
			self.partition:removeProp (item.prop)
		end,
		replace = function (self, itemOld, itemNew)
			self:remove (itemOld)
			self:add (itemNew, itemOld.slot)
		end
	}
	
	t.layer:setViewport ( viewport )
	t.camera:setLoc ( viewport.w/2 - tray_h/2, viewport.h/2 - tray_h/2 )
	t.layer:setCamera ( t.camera )
	t.layer:setPartition ( t.partition )

	t.background = NewColorLayer (viewport, 0.25, 0.25, 0.25, 0.5, viewport.w, tray_h)
	t.background:setLoc ( 0, -viewport.h/2 + tray_h/2 )

	table.insert (ActiveLayers, t)
	MOAISim.pushRenderPass ( t.background.layer )
	MOAISim.pushRenderPass ( t.layer )
	
	return t
end

function ReplaceItemImage (prop, name)
	SwitchDeck (prop, name)
end

-- Snaps the given item's position to an 8x8 pixel grid, or (optionally) 16 pixels at ground level.
function Snap ( item, ground_snap )
	x, y = item.prop:getLoc ()
	bottom_y = y - item.h/2
	x = math.floor ( (x+4)/8 ) * 8
	bottom_y = math.floor ( (bottom_y+4)/8 ) * 8
	if ground_snap then
		if math.abs (bottom_y) < 16 then bottom_y = 0 end  -- larger snap at ground level
	end
	item.prop:setLoc ( x, bottom_y + item.h/2 )
	return item
end


--[[ Performs a shallow copy of table t.
	 Preserves list length property and metatable reference. ]]
function copy ( t )
	-- Copy all list elements of t
	local r = {}
	for i = 1, #t do
		table.insert ( r, t[i] )
	end
	-- Copy the non-list key/value pairs
	for k, v in pairs ( t ) do
		if r[k] == nil then r[k] = v end
	end
	-- Copy the metatable reference
	local m = getmetatable ( t )
	if m ~= nil then setmetatable ( r, m ) end
	-- Done.
	return r
end

--[[ Copies elements of table t into table r. List elements are appended, hash elements overridden. ]]
function copyInto ( t, r )
	-- Copy all list elements of t
	local copied = {}
	for i = 1, #t do
		table.insert ( copied, t[i] )
		table.insert ( r, t[i] )
	end
	-- Copy the non-list key/value pairs
	for k, v in pairs ( t ) do
		if copied[k] == nil then r[k] = v end
	end
end

--[[ Given any value, returns an escaped string for that value.
	 If v is a table, then its elements may be indented. Indent default is 1.
	 ]]
function stringizeValue ( v, indent )
	if type (v) == "table" then
		if indent == nil then indent = 1 end
		--local indentString = string.rep ( "    ", indent )
		local completed = {}  -- keys that have been completed already
		local result = {}   -- lines in result
		-- Do list elements first
		for key, value in ipairs ( v ) do
			table.insert ( result, stringizeValue ( value, indent + 1 ) )
			completed [ key ] = true
		end
		-- Do non-list elements next
		for key, value in pairs ( v ) do
			if completed [ key ] == nil then  -- make sure not been done already
				local entry = stringizeKey ( key ) .. ' = ' .. stringizeValue ( value, indent + 1 )
				table.insert ( result, entry )
			end
		end
		-- Combine everything
		local all = table.concat ( result, ',\n' .. string.rep ( "    ", indent ) )
		local newline_at = string.find ( all, "[\n\r]" )
		if newline_at == nil then
			return '{ ' .. all .. ' }'
		else
			return '{\n' .. string.rep ( "    ", indent ) .. all .. '\n' ..
				string.rep ( "    ", indent - 1 ) .. '}'
		end
	end
	--
	if type (v) == "boolean" then
		return tostring (v)
	end
	--
	local n = tonumber (v)
	if n ~= nil then
		return tostring (n)
	end
	--
	local s = string.gsub ( tostring(v), '\\', '\\\\' )
	s = string.gsub ( s, '"', '\\"' )
	s = string.gsub ( s, "\n", "\\n" )
	s = string.gsub ( s, "\r", "\\r" )
	return '"' .. s .. '"'
end
--[[ Returns a value k as a string suitable for use as a table constructor key. ]]
function stringizeKey ( k )
	if type (k) == "boolean" then
		return '[' .. tostring (k) .. ']'
	end
	--
	local n = tonumber (k)
	if n ~= nil then
		return '[' .. tostring (n) .. ']'
	end
	--
	local s = string.gsub ( tostring(k), '\\', '\\\\' )
	s = string.gsub ( s, '"', '\\"' )
	s = string.gsub ( s, "\n", "\\n" )
	s = string.gsub ( s, "\r", "\\r" )
	non_word_at = string.find ( s, "[^%w_]" )
	--
	if s == "" then
		return '[""]'
	end
	if non_word_at == nil and string.find ( string.sub (s, 1, 1), "[%a_]" ) ~= nil then
		return s
	else
		return '["' .. s .. '"]'
	end
end

--[[ Saves a simple table to a file. ]]
function saveTable ( t, file_name )
	f = io.open ( file_name, "wb" )
	f:write ( "return " )
	f:write ( stringizeValue (t) )
	f:close ()
end

--[[ Loads a table from a file. ]]
function loadTable ( file_name )
	return dofile ( file_name )
end

Physics = {}  -- filename -> physics_info
local SingleQuads = {}

function LoadPropsFromTable (t, surface)
	local max_priority = 0
	for i, data in ipairs (t or {}) do
		local prop = CreateProp (data.name)
		prop:setPriority (data.priority)
		PlaceInLayer (surface, prop, data.x, data.y)
		max_priority = math.max (max_priority, data.priority + 1)
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

function ClearLevel ()
	GameSurface:clearProps ()
	BackgroundSurface1:clearProps ()
	BackgroundSurface2:clearProps ()
end

function FileExists (filename)
	local f = io.open (filename)
	if f then io.close (f) return true else return false end
end

function LoadLevel (level_filename)
	if FileExists (level_filename) then
		-- Load level file.
		ClearLevel ()
		local all = dofile (level_filename)
		local p1 = LoadPropsFromTable (all.GameSurface, GameSurface)
		local p2 = LoadPropsFromTable (all.BackgroundSurface2, BackgroundSurface2)
		local p3 = LoadPropsFromTable (all.BackgroundSurface1, BackgroundSurface1)
		LoadPropPhysicsTable (all.PhysicsTable)
		return math.max (p1, p2, p3)
	else
		-- File doesn't exist. Start empty level.
		ClearLevel ()
		LoadPropPhysicsTable (nil)  -- TODO: store physics info in separate file?
		return 1
	end
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

function PlaceInLayer (surface, prop, x, y)
	prop:setLoc (x, y)
	surface.partition:insertProp (prop)
	surface.props[prop] = true
	
	-- Custom parameters. TODO: remove these, if possible
	prop.prop = prop
	prop.data = prop
	prop.layerdata = surface
	prop.layer = surface.layer
	prop.partition = surface.partition
	
	return prop
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
	local physics = Physics[prop.name] or {}
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
	
	Physics[prop.name] = physics
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
	local w = propdata.w * propdata.basicScale
	local h = propdata.h * propdata.basicScale
	local center_x, center_y = propdata.prop:getLoc ()
	local box_x = world_x - (center_x - w / 2)
	local box_y = h - (world_y - center_y + h / 2)  -- inverted y-axis.
	
	-- Check against width/height to see if inside prop boundaries
	if box_x < 0 or box_y < 0 or box_x >= w or box_y >= h then
		return false
	end
	
	-- Translate coordinates according to the current animation frame
	local image_x, image_y = propdata:animCoordImage (
		box_x / propdata.basicScale, box_y / propdata.basicScale)
	
	-- Load image (if not already loaded) and query the correct pixel
	r, g, b, a = LoadImage (propdata.name):getRGBA (image_x, image_y)
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
	
	prop_type.prop = prop_type  -- TODO: remove when possible
	
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
	prop_type:setLoc (prop_type.trayX, prop_type.trayY)
	prop_type:setScl (prop_type.trayScl)
	tray.partition:insertProp (prop_type)
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

function LoadProp (series, name)
	local prop = CreateProp (name)
	if not PropsByType[series] then PropsByType[series] = {} end
	table.insert (PropsByType[series], prop)
	return prop
end
