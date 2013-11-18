--world.lua

----------------------------------------------------------------
-- This file contains all of the world functions
----------------------------------------------------------------

-- define layers
world = MOAIBox2DWorld.new()
world:setGravity(0, -_gravity_)
world:setUnitsToMeters(1/_scale_)

-- setup grounds
-- setup ground
ground = {}
ground.verts1 = {
-320,-20,
320,-20
}
ground.verts2 = {
}
ground.verts3 = {
}
ground.verts4 = {
}

ground.body = world:addBody( MOAIBox2DBody.STATIC, 0, -60 )
ground.body.tag = 'ground'
ground.fixtures = {
    ground.body:addChain( ground.verts1 ),
   --ground.body:addChain( ground.verts2 ),
    --ground.body:addChain( ground.verts3 ),
    --ground.body:addChain( ground.verts4 )
}
ground.fixtures[1]:setFriction( _worldFriction_ )
--ground.fixtures[2]:setFriction( _worldFriction_ )
--ground.fixtures[3]:setFriction( _worldFriction_ )
--ground.fixtures[4]:setFriction( _worldFriction_ )


