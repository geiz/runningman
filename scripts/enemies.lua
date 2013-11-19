--enemies.lua
----------------------------------------------------------------
-- This file contains all functions for spawning enemies
----------------------------------------------------------------


-- setup Enemies
testAnim = CreateProp ("player_anim")

e = {}
for i=1,_eLength_ do
	e[i] = createObj(-10,10, 10,-10, 'enemy', CreateProp("tree1small") , 20*i, 20*i, 'dynamic', 1)
end
e1 = createObj(-10,10, 10,-10, 'enemy', testAnim, -20, 20, 'kinematic')
e2 = createObj(-10,10, 10,-10, 'enemy', testAnim, 0, 20, 'static')
--enemy = createEntity(-10,10, 10,-10, 'enemy', testAnim, -20, -20)

