-- This file contains information about images and animations

return {
	player_anim = {
		filename = "numbers.png",
		width = 32,
		height = 32,
		scale = 1/2,
		
		idle = {
			first_frame = 1,
			last_frame = 64
		}
	},
	player_slash_anim = { -- TODO: Should this animation be in the player_anim image?
		filename = "slash1-3frames.png",
		width = 116,
		height = 75,
		scale = 1/12,
		
		slash = {
			first_frame = 1,
			last_frame = 3
		}
	},
	
	tileG = {
		filename = "tileG.png",
		ui_only = true,
	},

	tileB1 = {
		filename = "tileB1.png",
		ui_only = true,
	},

	tileB2 = {
		filename = "tileB2.png",
		ui_only = true,
	},

	bgImg = {
		filename = "testMap.png",
	},
	
	explosion1 = {
		filename = "explosion.png",
		scale = 1/20
	},
	
	bullet = {
		filename = "explosion.png",
		scale = 1/12
	},
	
	bomb_small = {
		filename = "bomb.png",
		scale = 1/16
	},
	
	tree1small = {
		filename = "tree-1.png",
		scale = 1/30
	},

	tree1 = {
		filename = "tree-1.png"
	},

	tree2 = {
		filename = "tree-2.png"
	},

	tree3 = {
		filename = "tree-3.png"
	},

	rock1 = {
		filename = "rock-1.png"
	},
	
	mountain1 = {
		filename = "mountain-1.png"
	},
	
	mountain2 = {
		filename = "mountain-2.png"
	},
	
	cohart = {
		filename = "cohart96.png"
	},
	
	squirrel = {
		filename = "Monster-squirrel.png",
		width = 32,
		height = 32,
		scale = 3,
		
		eating = {
			first_frame = 1,
			last_frame = 4
		},
		idle = {
			first_frame = 5,
			last_frame = 8
		},
		default = { first_frame = 47 }
	},
	
	hero1 = {
		filename = "hero1-idle.png",
		width = 50,
		height = 56,
		idle = {
			first_frame = 1,
			frames = 2
		},
		slash = {
			filename = "slash1-3frames.png",
			width = 128,
			height = 75,
			first_frame = 1,
			frames = 3
		}
	},

	ninja1 = {
		filename = "cuteninja.png"
	}
}
