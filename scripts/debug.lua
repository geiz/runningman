-- debug.lua

----------------------------------------------------------------
-- This file contains debug options when enabled.
----------------------------------------------------------------



if _debugMode_ then
    
    print("Debug Mode Enabled")
        -- Debug Text
    debug = MOAITextBox.new()
    debug:setRect( -_stage_.w/2, -_stage_.h/2, _stage_.w/2, _stage_.h/2 )
    debug:setYFlip( true )
    debug:setColor( 1, 1, 1 )
    debug:setString( 'debug' )
    debug.font = MOAIFont.new()
    debug.font:load( 'data/verdana.ttf' )
    debug.font:preloadGlyphs( _charCode_, _fontScale_ )
    debug:setFont( debug.font )

    -- 
    layerDebug:setViewport( viewport )
    layerDebug:insertProp( debug )
    MOAISim.pushRenderPass(layerDebug)

    -- update function for debugStatus box
    debugStatusThread = MOAICoroutine.new()
    debugStatusThread:run( 
    function ()
        while true do
            local x, y = player.body:getWorldCenter()
            local dx, dy = player.body:getLinearVelocity()
            debug:setString( 'x, y:   ' .. math.ceil( x ) .. ', ' .. math.ceil( y )
                         .. '\ndx, dy: ' .. math.ceil( dx ) .. ', ' .. math.ceil( dy )
                         .. '\nOn Ground: ' .. ( player.onGround and 'true' or 'false' )
                         .. '\nContact Count: ' .. player.currentContactCount
                         .. '\nPlatform: ' .. ( player.platform and 'true' or 'false' ) )
            coroutine.yield()
        end
    end )

else
    print("Debug Mode Disabled")
end