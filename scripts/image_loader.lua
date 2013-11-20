local ConfigTable = dofile ('image_config.lua')
local loadedDecks = {}
local loadedImages = {}

function CreateProp (type_name)
-- Creates a prop with the given type_name, where type_name is a key in
-- the image config table.

	if not ConfigTable[type_name] then
		error ("ERROR: invalid type_name '%s' passed to CreateProp.\n" ..
			"    Perhaps an entry in image_config.lua is missing?", tostring (type_name))
		return nil
	end

	local prop = MOAIProp2D.new()
	SwitchDeck (prop, type_name)
	
	return prop
end

function SwitchDeck (prop, type_name)
-- Sets the prop to the given config type.
-- Makes any necessary adjustments to the prop's parameters.

	-- Get configuration info about this prop type
	local config = ConfigTable[type_name]
	if not ConfigTable[type_name] then
		error ("ERROR: invalid type_name '%s' passed to SwitchDec.\n" ..
			"    Perhaps an entry in image_config.lua is missing?", tostring (type_name))
		return nil
	end

	-- Figure out which folder the image is in
	local folder = _imgFolder_
	if isAnim (type_name) then
		folder = _animFolder_
	end

	-- Load the deck
	local deck = LoadTextureAsDeck (folder .. config.filename, config.width, config.height)
	prop:setDeck (deck)
	
	-- Deal with scaling
	prop.basicScale = config.scale or 1
	prop:setScl (prop.basicScale)
	
	-- Set default animation frame
	local default_anim = config.default or config.idle
	if default_anim then
		prop:setIndex (default_anim.first_frame or 1)
	else
		prop:setIndex (1)
	end
	
	-- Set misc. info
	prop.w, prop.h = deck.w, deck.h
	prop.name = type_name
end

function isAnim (type_name)
-- Returns true if the image type has animations.
-- This is how we choose: if any values in the configuation are tables,
--   then assume this is an animation. Otherwise assume it is not.
	for k,v in pairs (ConfigTable[type_name]) do
		if type (v) == 'table' then return true end
	end
	return false
end

function LoadTextureAsDeck (filename, tile_w, tile_h)
-- Loads a texture from a file. Returns a deck.
-- tile_w and tile_h default to texture width and height.
-- If a deck with the filename has previously been created, that deck wil be returned.

	-- Has this deck already been created?
	if loadedDecks[filename] then return loadedDecks[filename] end
	
	-- Load the texture.
	local texture = MOAITexture.new()
	texture:load (filename)

	-- Compute tile size, tiles across, and uv texture dimensions
	local texture_w, texture_h = texture:getSize()
	
	tile_w = tile_w or texture_w
	tile_h = tile_h or texture_h

	local tiles_wide = math.floor (texture_w / tile_w)
	local tiles_high = math.floor (texture_h / tile_h)
	
	local uv_width = tile_w / texture_w
	local uv_height = tile_h / texture_h
	
	-- Create deck.
	local deck = MOAITileDeck2D.new()
	deck:setTexture (texture)
	deck:setSize (tiles_wide, tiles_high, uv_width, uv_height, 0, 0)
	deck:setRect (-tile_w/2, -tile_h/2, tile_w/2, tile_h/2)
	loadedDecks[filename] = deck
	
	-- Set custom fields
	deck.w = tile_w
	deck.h = tile_h
	
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

function LoadImageRaw (filename)
	-- Has this image already been loaded?
	if loadedImages[filename] then return loadedImages[filename] end
	-- Load the image
	loadedImages[filename] = MOAIImage.new()
	loadedImages[filename]:load (filename)
	-- Set custom fields
	loadedImages[filename].w, loadedImages[filename].h = loadedImages[filename]:getSize()
	
	return loadedImages[filename]
end
