local ConfigTable = dofile ('image_config.lua')
local loadedDecks = {}
local loadedTextures = {}
local loadedImages = {}

function ForEachImage (f)
-- Calls f(name, data) for each item in image config table
	for name, data in pairs (ConfigTable) do
		f (name, data)
	end
end

function CreateProp (name)
-- Creates a prop with the given type_name, where type_name is a key in
-- the image config table.

	if not ConfigTable[name] then
		error ("ERROR: invalid name '%s' passed to CreateProp.\n" ..
			"    Perhaps an entry in image_config.lua is missing?", tostring (name))
		return nil
	end

	local prop = MOAIProp2D.new()
	SwitchDeck (prop, name)
	
	return prop
end

function ResetImageLoader ()
-- Clears all textures, decks, and images; and reloads image config file
	ConfigTable = dofile ('image_config.lua')
	loadedDecks = {}
	loadedTextures = {}
	loadedImages = {}
end

function SwitchDeck (prop, name)
-- Sets the prop to the given config name.
-- Makes any necessary adjustments to the prop's parameters.
-- Sets prop.scale to the scale in the config file. NOT the same as using the setScl function!

	local config = ConfigTable[name]

	-- Create a deck with the given config name.
	local deck = CreateDeck (name)
	prop:setDeck (deck)
	
	-- Set default animation frame
	local default_anim = config.default or config.idle
	if default_anim then
		prop.first_frame = default_anim.first_frame or 1
		prop.last_frame = default_anim.last_frame or prop.first_frame
	else
		prop.first_frame = 1
		prop.last_frame = 1
	end
	prop:setIndex (prop.first_frame)
	
	-- Function to translate image-space coordinates according to animation frame.
	function prop:animCoordImage (x, y)
		-- Find out which frame of animation we're on, and transform accordingly.
		local index = self:getIndex ()
		local row = math.floor ((index - 1) / self.deck.tiles_wide) % self.deck.tiles_high
		local col = (index - 1) % self.deck.tiles_wide
		return x/prop.scale + col * self.deck.tile_w, y/prop.scale + row * self.deck.tile_h
	end
	
	-- Set misc. info
	prop.w = deck.w
	prop.h = deck.h
	prop.scale = deck.scale
	prop.deck = deck
	prop.name = name
end

function isAnim (name)
-- Returns true if the image type has animations.
-- This is how we choose: if any values in the configuation are tables,
--   then assume this is an animation. Otherwise assume it is not.
	for k,v in pairs (ConfigTable[name]) do
		if type (v) == 'table' then return true end
	end
	return false
end

function LoadTexture (filename)
-- Loads a texture from a file.
-- If the texture filename was already loaded, does not load again.
	local texture = loadedTextures[filename]
	if not texture then
		texture = MOAITexture.new()
		texture:load (filename)
		loadedTextures[filename] = texture
	end
	return texture
end

function CreateDeck (name)
-- Creates a deck from the named configuration.
-- If a deck has already been created for this configuration, just return it.
-- Config width and height are assumed to be the pixel size of the image tile.
-- To scale the image to a different size, the scale should be set.

	-- Has this deck already been created?
	if loadedDecks[name] then return loadedDecks[name] end
	
	-- Get configuration info for this name
	local config = ConfigTable[name]
	if not ConfigTable[name] then
		error ("ERROR: invalid name '%s' passed to SwitchDeck.\n" ..
			"    Perhaps an entry in image_config.lua is missing?", tostring (name))
		return nil
	end

	-- Figure out which folder the texture image is in
	local folder = _imgFolder_
	if isAnim (name) then
		folder = _animFolder_
	end

	-- Load the texture.
	local texture = LoadTexture (folder .. config.filename)

	-- Compute tile size, tiles across, and uv texture dimensions
	local texture_w, texture_h = texture:getSize()
	local tile_w = config.width or texture_w
	local tile_h = config.height or texture_h
	local scale = config.scale or 1

	local tiles_wide = math.floor (texture_w / tile_w)
	local tiles_high = math.floor (texture_h / tile_h)
	
	local uv_width = tile_w / texture_w
	local uv_height = tile_h / texture_h
	
	-- Create deck.
	local deck = MOAITileDeck2D.new()
	local rect_w = tile_w * scale
	local rect_h = tile_h * scale
	deck:setTexture (texture)
	deck:setSize (tiles_wide, tiles_high, uv_width, uv_height, 0, 0)
	deck:setRect (-rect_w/2, -rect_h/2, rect_w/2, rect_h/2)
	loadedDecks[name] = deck
	
	-- Set custom fields
	deck.w = rect_w
	deck.h = rect_h
	deck.scale = scale
	deck.tile_w = tile_w
	deck.tile_h = tile_h
	deck.tiles_wide = tiles_wide
	deck.tiles_high = tiles_high
	
	return deck
end

function LoadImage (name)
-- Loads an image from a file. Returns a MOAIImage.
-- If the name parameter is a type name in the config file, then load its image.
--   Otherwise, name is interpreted as a file name in the images folder.

	-- Get configuration info about this prop type
	local config = ConfigTable[name]
	if not config then
		return LoadImageRaw (_imgFolder_ .. name)
	end

	-- Figure out which folder the image is in
	local folder = _imgFolder_
	if isAnim (name) then
		folder = _animFolder_
	end
	
	local image = LoadImageRaw (folder .. config.filename)
	return image
end

function LoadImageRaw (filename, tile_w, tile_h)
	-- Has this image already been loaded?
	if loadedImages[filename] then return loadedImages[filename] end
	
	-- Load the image
	local image = MOAIImage.new()
	image:load (filename)

	-- Compute tile size and tiles across
	local image_w, image_h = image:getSize()
	
	tile_w = tile_w or image_w
	tile_h = tile_h or image_h

	local tiles_wide = math.floor (image_w / tile_w)
	local tiles_high = math.floor (image_h / tile_h)
	
	-- Set custom fields
	image.w = tile_w
	image.h = tile_h
	image.tile_w = tile_w
	image.tile_h = tile_h
	image.tiles_wide = tiles_wide
	image.tiles_high = tiles_high
	
	loadedImages[filename] = image
	return image
end
