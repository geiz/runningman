local ConfigTable = dofile ('image_config.lua')
local loadedDecks = {}
local loadedImages = {}

function CreateProp (type_name)
	-- Get configuration info about this prop type
	local config = ConfigTable[type_name]

	-- Figure out which folder the image is in
	local folder = _imgFolder
	if isAnim (type_name) then
		folder = _animFolder
	end
	
	-- Create a prop
	local prop = MOAIProp2D.new()
	prop:setDeck (LoadTextureAsDeck (folder .. config.filename, config.width, config.height))
	prop:setScl (config.scale or 1)
	
	-- Set default animation frame
	local default_anim = t.default or t.idle
	if default_anim then
		prop:setIndex (default_anim.first_frame or 1)
	else
		prop:setIndex (1)
	
	return prop
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
	
	return deck
end

function LoadImage (name)
-- Loads an image from a file. Returns a MOAIImage.
-- If the name parameter is a type name in the config file, then load its image.
--   Otherwise, name is interpreted as a raw file name (see LoadImageRaw).

	-- Get configuration info about this prop type
	local config = ConfigTable[name]
	if not config then
		return LoadImageRaw (name)
	end

	-- Figure out which folder the image is in
	local folder = _imgFolder
	if isAnim (name) then
		folder = _animFolder
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
	return loadedImages[filename]
end
