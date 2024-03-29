dofile ('initialize.lua')
extend ('util.lua')
extend ('image_loader.lua')
extend ('physics_loader.lua')
extend ('editor_ui.lua')
extend ('game_ui.lua')

local scale = 1

-- Create the viewport and primary camera
view_w, view_h, tray_h = 960, 640, 80*scale
viewport = OpenViewport ('Editor Tool', view_w*scale, view_h*scale)
EditorCamera = MOAICamera2D.new ()
EditorCamera:setScl (1 / scale)
camera = EditorCamera

-- Create game surfaces and tray
GameSurface = CreateLayer (viewport, EditorCamera)
BackgroundSurface2 = CreateLayer (viewport, EditorCamera, 0.5, 0.85)
BackgroundSurface1 = CreateLayer (viewport, EditorCamera, 0.25, 0.888)
BackgroundSurface1.layer:setClearColor (1,1,1)  -- Set this surface to clear the screen
tray = CreateTray (tray_h * 4/5, tray_h)
PositionTray (tray, "BOTTOM", viewport)

_priority_ = LoadLevel (_levelFolder_ .. _levelFile_)

function LoadAllProps ()
	local loaded = {}  -- keep track of what we've already loaded
	
	-- Load basic UI tile set
	modeTile = LoadProp ("ui", "tileG")
	loaded["tileG"] = true
	
	-- Load tiles with physics info
	ForEachPhysicsObject (
		function (name, config)
			LoadProp ("game", name)
			loaded[name] = true
		end
	)
	
	-- Load all other tiles
	ForEachImage (
		function (name, config)
			if not loaded[name] and not config.ui_only then
				LoadProp ("background", name)
			end
		end
	)
end

function GetPropInfo (surface)
	local all = {}
	for data in pairs(surface.props) do
		local out = { name = data.name }
		out.x, out.y = data.prop:getLoc ()
		out.priority = data.prop:getPriority ()
		table.insert (all, out)
	end
	return all
end

function SaveLevel (level_filename)
	local level = {
		GameSurface = GetPropInfo (GameSurface),
		BackgroundSurface1 = GetPropInfo (BackgroundSurface1),
		BackgroundSurface2 = GetPropInfo (BackgroundSurface2),
	}
	saveTable (level, level_filename)
end

ChainInEditorUI ()

PhysicsEditorOn = false

function SetPhysicsEditorMode (on)
	if on then
		PhysicsEditorCamera = PhysicsEditorCamera or MOAICamera2D.new ()
		PhysicsEditorSurface = PhysicsEditorSurface or CreateLayer (viewport, PhysicsEditorCamera)
		PhysicsEditorBackground = PhysicsEditorBackground or CreateLayer (viewport, PhysicsEditorCamera)
		PhysicsEditorBackground.layer:setClearColor (1,1,1)  -- Set this surface to clear the screen
		PhysicsEditorBackground.allow_picking = false
		PhysicsEditorSurface.pixel_alpha_picking = false
		camera = PhysicsEditorCamera
		
		ResetTray (tray, "game")
		ShowLayers (PhysicsEditorBackground, PhysicsEditorSurface, tray)
		TargetSurface = PhysicsEditorSurface
		PhysicsEditorOn = true
	else
		PhysicsEditorOn = false
		camera = EditorCamera
		SetEditorMode (EditMode)
	end
end

InPlayMode = false

function GoIntoPlayMode ()
	ResetTray (tray, nil)
	ShowLayers (BackgroundSurface1, BackgroundSurface2, GameSurface)
	TargetSurface = GameSurface
	ChainOutEditorUI ()
	InPlayMode = true
	ChainInGameUI ()
end

function GoOutOfPlayMode ()
	ChainOutGameUI ()
	InPlayMode = false
	ChainInEditorUI ()
	SetPhysicsEditorMode (false)  -- also resets other editor modes
end

function SetEditorMode (m)
	EditMode = m
	if m == "G" then
		ReplaceItemImage (modeTile, "tileG")
		ResetTray (tray, "ui", "game")
		ShowLayers (BackgroundSurface1, BackgroundSurface2, GameSurface, tray)
		TargetSurface = GameSurface
	end
	if m == "B2" then
		ReplaceItemImage (modeTile, "tileB2")
		ResetTray (tray, "ui", "background")
		ShowLayers (BackgroundSurface1, BackgroundSurface2, tray)
		TargetSurface = BackgroundSurface2
	end
	if m == "B1" then
		ReplaceItemImage (modeTile, "tileB1")
		ResetTray (tray, "ui", "background")
		ShowLayers (BackgroundSurface1, tray)
		TargetSurface = BackgroundSurface1
	end
end

NextMode = { B1="B2", B2="G", G="B1" }

LoadAllProps ()

SetEditorMode ("G")
