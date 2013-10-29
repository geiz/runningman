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

function ReplaceItemImage (item, newName)
	-- Make sure an ItemInfo entry exists and its file is loaded
	if not ItemInfo[newName] then ItemInfo[newName] = { filename = newName } end
	if not ItemInfo[newName].image then
		ItemInfo[newName].image = MOAITexture.new ()
		ItemInfo[newName].image:load (ItemInfo[newName].filename)
	end
	-- Perform replacement and update info
	copyInto (ItemInfo[newName], item)
	item.w, item.h = item.image:getSize ()
	item.deck:setTexture ( item.image )
	item.deck:setRect ( -item.w/2, -item.h/2, item.w/2, item.h/2 )
	return item
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
