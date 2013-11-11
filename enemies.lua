--enemies.lua
----------------------------------------------------------------
-- This file contains all functions for spawning enemies
----------------------------------------------------------------


-- setup Enemies
dofile("entity.lua")

testAnim = newTileAnim(_playerAnim, 15,15,8,8)

e = {}
for i=1,_eLength do
	e[i] = createObj(-10,10, 10,-10, 'enemy', newImg(_tree1, 15,15) , 20*i, 20*i, 'dynamic', 1)
end
e1 = createObj(-10,10, 10,-10, 'enemy', testAnim, -20, 20, 'kinematic')
e2 = createObj(-10,10, 10,-10, 'enemy', testAnim, 0, 20, 'static')
--enemy = createEntity(-10,10, 10,-10, 'enemy', testAnim, -20, -20)

