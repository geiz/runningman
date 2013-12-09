-- player.lua


-- setup player
player = {}
player.onGround = false
player.currentContactCount = 0
player.move = {
    left = false,
    right = false
}
player.tp = false
player.dash = false

player.platform = nil
player.doubleJumped = false
player.verts = {
    -10, 10,
    -10, -10,
    10, -10,
    10, 10
}
player.body = world:addBody( MOAIBox2DBody.DYNAMIC )
player.body.tag = 'player'
player.body:setFixedRotation( false )
player.body:setMassData( 80 )
player.body:resetMassData()
player.body.velocity = _playerDefaultVelocity_

player.polygon = player.body:addPolygon( player.verts )
player.rect = player.body:addRect( -10, -10, 10, 10 )
player.polygon :setRestitution( 0 ) -- valid value between 0 - 1
player.polygon :setFriction( 1 )
player.rect:setSensor( true )
player.body.direction = 0 -- 0 = left, 1 = right

-- Creates and adds player prop to the layer
--[[
player.prop = CreateProp("ninja1")
player.prop:setParent(player.body)
GameSurface.partition:insertProp (player.prop)
GameSurface.props[player.prop] = true]]


-- locks camera to player
GameCamera:setParent(player.body)
