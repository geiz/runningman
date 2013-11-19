-- This file contains information about images and animations

return {
	rock1 = {
		filename = "rock-1.png"
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
	}
}
