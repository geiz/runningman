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

-------- player body imgs/settings
--player.body.prop = newImg("hero1-idle.png",10,16)
player.body.anim = newTileAnim(_playerAnim_, 15, 15, 8, 8)
--player.body.prop = newImg("hero1-idle.png",10,16)
player.body.anim:setParent(player.body)
player.body.direction = 0 -- 0 = left, 1 = right
player.bullets = {}
--------
-------- player attack imgs/settings
-- 
player.attack = world:addBody( MOAIBox2DBody.DYNAMIC )
player.attack.tag = 'bomb'
player.attack:setFixedRotation( false)
player.attack:setMassData(10)
player.attack:resetMassData()


player.attack.timedbomb = {}
player.attack.timedbomb.attacking = false
player.attack.timedbomb.prop = newImg("bomb.png",8,8)

player.attack.slash1 = {}
player.attack.slash1.attacking = false
player.attack.slash1.anim = newTileAnim("slash1-3frames.png", 15, 15, 3, 1)
--player.attack.slash1.prop = newImg("slash1-3frames.png",10,16,3,1)
--player.attack.slash1.prop:setparent(player.body)
--player.attack.prop:setParent(player.body)