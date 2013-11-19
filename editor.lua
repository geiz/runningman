dofile ("initialize.lua")
extend ('util.lua')
extend ('editor_ui.lua')
extend ('game_ui.lua')

-- Create the viewport and primary camera
view_w, view_h, tray_h = 960, 640, 80
viewport = OpenViewport ('Editor Tool', view_w, view_h)
EditorCamera = MOAICamera2D.new ()
EditorCamera:setLoc ( viewport.w/2, viewport.h/2 - tray_h )
camera = EditorCamera

-- Create game surfaces and tray
GameSurface = CreateLayer (viewport, EditorCamera)
BackgroundSurface2 = CreateLayer (viewport, EditorCamera, 0.5, 0.85)
BackgroundSurface1 = CreateLayer (viewport, EditorCamera, 0.25, 0.8)
BackgroundSurface1.layer:setClearColor (1,1,1)  -- Set this surface to clear the screen
tray = CreateTray (64, 80)
PositionTray (tray, "BOTTOM", viewport)

priority = LoadLevel ('working_levels/level001.lv')

function GetPropInfo (surface)
	local all = {}
	for data in pairs(surface.props) do
		local out = {
			w = data.w, h = data.h,
			filename = data.filename
		}
		out.x, out.y = data.prop:getLoc ()
		out.scale = data.prop:getScl ()
		out.priority = data.prop:getPriority ()
		table.insert (all, out)
	end
	return all
end

function SaveLevel (level_filename)
	local level = {
		PhysicsTable = GetPropPhysicsTable (),
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
		
		ResetTray (tray, "gametile")
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
		ReplaceItemImage (modeTile, "tileG.png")
		ResetTray (tray, "basic", "gametile")
		ShowLayers (BackgroundSurface1, BackgroundSurface2, GameSurface, tray)
		TargetSurface = GameSurface
	end
	if m == "B2" then
		ReplaceItemImage (modeTile, "tileB2.png")
		ResetTray (tray, "basic", "gametile")
		ShowLayers (BackgroundSurface1, BackgroundSurface2, tray)
		TargetSurface = BackgroundSurface2
	end
	if m == "B1" then
		ReplaceItemImage (modeTile, "tileB1.png")
		ResetTray (tray, "basic", "gametile")
		ShowLayers (BackgroundSurface1, tray)
		TargetSurface = BackgroundSurface1
	end
end

NextMode = { B1="B2", B2="G", G="B1" }

modeTile = LoadProp ("basic", "tileG.png")
LoadProp ("gametile", "cohart96.png")
LoadProp ("gametile", "rock-1.png")
LoadProp ("gametile", "mountain-1.png")
LoadProp ("gametile", "mountain-2.png")
LoadProp ("gametile", "tree-1.png")
LoadProp ("gametile", "tree-2.png")
LoadProp ("gametile", "tree-3.png")

SetEditorMode ("B1")
