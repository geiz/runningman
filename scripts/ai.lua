local t = dofile ('level001.lv')

local polygon = t.PhysicsTable["Rock-1.png"].nodes





function enemy1Update ()
	if enemy1Health < x then
		return
	end
	
	if enemy1NearPlayer then
		return
	end
	
	--... etc...
end


function update ()  -- call 30x/sec

	enemy1Update ()
	enemy2Update ()
	enemy3Update ()

	playerUpdate ()

end
